# == Schema Information
#
# Table name: core_team_projects
#
#  id              :integer          not null, primary key
#  core_team_id    :integer
#  core_project_id :integer
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::TeamProject < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_team_projects"
  include WhoDidIt
  include WhoDidItOrganisation
  include WhoDidItProject

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :core_team, class_name: "Core::Team", foreign_key: "core_team_id"
  
  #VALIDATIONS
  validates :core_team_id, presence: true
  validates :core_project_id, presence: true
  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def to_s
    self.core_team.to_s
  end
  
  def self.account_id
    self.core_team.organisation_id
  end
  
  #PRIVATE
  private
  
end
