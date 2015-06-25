# == Schema Information
#
# Table name: core_permissions
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  role            :string
#  email           :string
#  status          :string
#  invited_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  is_owner_team   :boolean
#  created_by      :integer
#  updated_by      :integer
#  core_project_id :integer
#

# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::Permission < ActiveRecord::Base

  #GEMS
  self.table_name = "core_permissions"
  include WhoDidIt
  
  #CONSTANTS  
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account
  belongs_to :core_account_email,class_name: "Core::AccountEmail", foreign_key: "email",primary_key: "email"
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  
  #VALIDATIONS
  validates :email, presence: true, format: {with: Constants::EMAIL}
  validates :role, presence: true
  validates :account_id, presence: true, on: :update
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  scope :owners, -> { where(role: Constants::ROLE_O) }
  scope :collaborators, -> { where(role: Constants::ROLE_C) }
  scope :invited, -> { where("account_id IS NULL") }
  scope :accepted, -> { where("account_id IS NOT NULL") }
  
  #CUSTOM SCOPES
  
  def set_account_id_if_email_found
    core_account_email = Core::AccountEmail.where(email: self.email).first
    if core_account_email.present?
      ac = core_account_email.account
      if ac.present?
        self.account_id = ac.id
        self.status = Constants::STATUS_A
      end
    end
  end
  
  #FUNCTIONS
  
  def to_s
    self.account_id.present? ? self.account.username : self.email
  end
  
  #PRIVATE
  
  private
  
  def before_create_set
    self.role = Constants::ROLE_C   if self.role.blank?
    self.status =  Constants::STATUS_A if self.status.blank?
    self.invited_at = Time.now
    true
  end
    
end
