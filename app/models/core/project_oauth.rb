# == Schema Information
#
# Table name: core_project_oauths
#
#  id              :integer          not null, primary key
#  core_project_id :integer
#  unique_id       :string(255)
#  provider        :string(255)
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  properties      :json
#

class Core::ProjectOauth < ActiveRecord::Base

  #GEMS
  self.table_name = "core_project_oauths"
  include WhoDidIt
  include WhoDidItProject
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  
  #VALIDATIONS
  validates :unique_id, presence: true
  validates :core_project_id, presence: true
  validates :provider, presence: true
  
  #CALLBACKS
  #SCOPES  
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def to_s
    if self.provider == "twitter"
      self.properties["info"]["name"]
    elsif self.provider == "google_oauth2"
      self.properties["info"]["email"]
    else
      self.unique_id
    end
  end
  
  def url
    if self.provider == "twitter"
      self.properties["info"]["urls"]["Twitter"]
    else
      nil
    end
  end
  
  def provider_to_s
    if self.provider == "google_oauth2"
      "Google Drive / Analytics"
    else
      self.provider
    end
  end
  
  #PRIVATE
  private

end
