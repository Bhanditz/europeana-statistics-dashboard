# == Schema Information
#
# Table name: cerebro_socials
#
#  id                 :integer          not null, primary key
#  cerebro_account_id :integer
#  source             :string(255)
#  source_name        :string(255)
#  photo_url          :text
#  bio                :text
#  url                :text
#  identifier         :string(255)
#  username           :string(255)
#  followers          :string(255)
#  following          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Cerebro::Social < ActiveRecord::Base
  
  #GEMS
  self.table_name = "cerebro_socials"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :cerebro_account, class_name: "Cerebro::Account", foreign_key: "cerebro_account_id"
  
  #VALIDATIONS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def self.extract(ca, photos, social_profiles)
    if photos.present?
      photos.each do |p|
        Cerebro::Social.create(cerebro_account_id: ca.id, source: p["type"], source_name: p["typeName"], photo_url: p["url"])
      end
    end
    if social_profiles.present?
      social_profiles.each do |so|
        c = ca.cerebro_socials.where(source: so["type"]).first
        c = Cerebro::Social.new(cerebro_account_id: ca.id, source: so["type"], source_name: so["typeName"]) if c.blank?
        c.bio = so["bio"]
        c.url = so["url"]
        c.username = so["username"]
        c.identifier = so["id"]
        c.followers = so["followers"]
        c.following = so["following"]
        c.save
      end
    end
  end
    
  #PRIVATE
  private
  
end
