# == Schema Information
#
# Table name: cerebro_accounts
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  account_id      :integer
#  properties      :hstore
#  response        :json
#  request_sent_at :datetime
#  status          :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Cerebro::Account < ActiveRecord::Base
  
  #GEMS
  require 'net/http'
  self.table_name = "cerebro_accounts"
  
  #CONSTANTS
  #ATTRIBUTES
  store_accessor :properties, :last_name, :full_name, :first_name, :location, :country_code, :state, :city, :age_range, :gender
  
  #ACCESSORS
  #ASSOCIATIONS
  has_many :cerebro_socials, class_name: "Cerebro::Social", foreign_key: "cerebro_account_id", dependent: :destroy
  has_many :cerebro_works, class_name: "Cerebro::Work", foreign_key: "cerebro_account_id", dependent: :destroy
  has_many :cerebro_websites, class_name: "Cerebro::Website", foreign_key: "cerebro_account_id", dependent: :destroy
  
  def acc
    Account.where(id: self.account_id).first
  end
  
  #CALLBACKS
  after_create :after_create_set
  
  #VALIDATIONS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def self.find_or_create(e, i)
    c = Cerebro::Account.where(email: e).first
    Cerebro::Account.create(email: e, account_id: i, request_sent_at: Time.now, status: "0", response: "{}")  if c.blank?
  end
  
  def extract
    j = self.response
    if j["contactInfo"].present?
      self.last_name = j["contactInfo"]["familyName"]
      self.full_name = j["contactInfo"]["fullName"]
      self.first_name = j["contactInfo"]["givenName"]
    end
    if j["demographics"].present?
      d = j["demographics"]
      self.location = d["locationGeneral"]
      if d["locationDeduced"].present?
        self.country_code = d["locationDeduced"]["country"]["code"] if d["locationDeduced"]["country"].present?
        self.state = d["locationDeduced"]["state"]["name"]          if d["locationDeduced"]["state"].present?
        self.city = d["locationDeduced"]["city"]["name"]            if d["locationDeduced"]["city"].present?
      end
      self.age_range = d["ageRange"]
      self.gender = d["gender"]
    end
    self.save
    if j["contactInfo"].present?
      Cerebro::Website.extract(self, j["contactInfo"]["websites"], "Websites")
      Cerebro::Website.extract(self, j["contactInfo"]["chats"], "Chats")
    end
    Cerebro::Social.extract(self, j["photos"], j["socialProfiles"])
    Cerebro::Work.extract(self, j["organizations"])
    #chats
    
    a             = self.acc
    a.name        = self.full_name if a.name.blank?
    a.location    = self.location  if a.location.blank?
    
    if a.image_url.blank?
      social_profiles = self.cerebro_socials.where("photo_url IS NOT NULL")
      if social_profiles.first.present?
        a.image_url   = social_profiles.first.photo_url
      end
    end
    
    if a.bio.blank?
      social_profiles = self.cerebro_socials.where("bio IS NOT NULL")
      if social_profiles.first.present?
        a.bio   = social_profiles.first.bio
      end
    end
    
    if a.company.blank?
      social_profiles = self.cerebro_works.where("end_date IS NULL").where(is_primary: "t")
      if social_profiles.first.present?
        a.company   = social_profiles.first.name
      end
    end
    
    if a.url.blank?
      social_profiles = self.cerebro_websites.where(genre: "Websites")
      if social_profiles.first.present?
        a.url   = social_profiles.first.url
      end
    end
    
    a.save
  end
    
  #PRIVATE
  private
  
  def after_create_set
    begin
      r = Nestful.get "https://api.fullcontact.com/v2/person.json?email=#{self.email}&apiKey=#{FULLCONTACT}&webhookId=#{self.email}&webhookUrl=#{CALLBACK_URL}/auth/fullcontact/callback"
      self.response = JSON.parse(r.body)
      self.status = self.response["status"]
    rescue 
      self.status = "404"
      self.response = "{}"
    end
    self.save
    return true
  end
  
end
