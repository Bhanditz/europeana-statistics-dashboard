# == Schema Information
#
# Table name: core_configuration_editors
#
#  id                :integer          not null, primary key
#  account_id        :integer
#  core_project_id   :integer
#  name              :string(255)
#  slug              :string(255)
#  to_publish        :boolean
#  last_published_at :datetime
#  content           :json
#  created_at        :datetime
#  updated_at        :datetime
#  properties        :hstore
#  created_by        :integer
#  updated_by        :integer
#

class Core::ConfigurationEditor < ActiveRecord::Base
  
  #GEMS
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :account
  self.table_name = "core_configuration_editors"
  include WhoDidIt
  include WhoDidItProject
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count, :marked_to_be_deleted
  
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :account
  
  #VALIDATIONS
  validates :name, presence: true, :uniqueness => { :case_sensitive => false }
  validates :account_id, presence: true
  validates :core_project_id, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  #----------------- PUBLISH TO CDN Functionality ------------------------------
  
  def to_s
    self.name
  end
  
  def s3_url 
    self.cdn_published_url
  end
  
  def s3_file_name
    self.account.slug + "/" + self.core_project.slug + "/configurations/" + self.slug + ".csv"
  end
  
  def generate_file_in_tmp(export_file_name)
    File.open(export_file_name, "w+") do |f|
      if self.content.present?
        f.write("key,value,default\n")
        self.content.each do |element|
          f.write("\"" + element["slug"].to_s + "\",\"" + element["value"].to_s + "\",\"" + element["default"].to_s+"\"\n") if !element.nil?
        end
      end
    end
  end
  
  #----------------- PUBLISH TO CDN Functionality ------------------------------
  
  #PRIVATE
  private
  
  def before_create_set
    self.to_publish = false
    self.cdn_published_count = "0"
    self.cdn_published_url = ""
    self.cdn_published_at = ""
    self.cdn_published_error = ""
    self.marked_to_be_deleted = "false"
    true
  end
  
  def should_generate_new_friendly_id?
    name_changed?
  end

end
