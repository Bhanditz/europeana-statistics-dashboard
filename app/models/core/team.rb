# == Schema Information
#
# Table name: core_teams
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  name            :string
#  created_by      :integer
#  updated_by      :integer
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#  role            :string
#  is_owner_team   :boolean
#

# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::Team < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_teams"
  include WhoDidIt
   
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :organisation, class_name: "Account", foreign_key: "organisation_id"
  has_many :core_team_projects, class_name: "Core::TeamProject", foreign_key: "core_team_id", dependent: :destroy #DONE
  has_many :core_permissions, class_name: "Core::Permission", foreign_key: "core_team_id" , dependent: :destroy #DONE
  has_many :core_projects, class_name: "Core::Project", through: :core_team_projects
  
  #VALIDATIONS
  validates :organisation_id, presence: true
  validates :name, presence: true
  validate  :validate_uniqueness
  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def to_s
    self.is_owner_team ? self.name : "#{self.name} (#{self.role})"
  end
  
  def in_team(ca, is_owner)
    c = Core::Permission.where(account_id: ca.id, organisation_id: self.organisation_id, email: ca.email, core_team_id: self.id).first
    if c.blank?
      Core::Permission.create!(account_id: ca.id, organisation_id: self.organisation_id, role: self.role, email: ca.email, core_team_id: self.id)
    else
      c.update_attributes(account_id: ca.id, organisation_id: self.organisation_id, role: self.role, email: ca.email, core_team_id: self.id)
    end
  end
  
  def out_of_team(ca)
    c = Core::Permission.where(account_id: ca.id, organisation_id: self.organisation_id, email: ca.email, core_team_id: self.id, role: self.role).first
    c.destroy
  end
  
  #PRIVATE
  private
  
  def validate_uniqueness
    if self.name_changed? and Core::Team.where(organisation_id: self.organisation_id, name: self.name, role: self.role).first.present?
      self.errors.add(:name, "already exists")
    end
  end
  
end
