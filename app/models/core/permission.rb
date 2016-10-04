# frozen_string_literal: true
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

class Core::Permission < ActiveRecord::Base
  # GEMS
  self.table_name = 'core_permissions'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  belongs_to :account
  belongs_to :core_project, class_name: 'Core::Project', foreign_key: 'core_project_id'

  # VALIDATIONS
  validates :email, presence: true, format: { with: Constants::EMAIL }
  validates :role, presence: true
  validates :account_id, presence: true, on: :update

  # CALLBACKS
  before_create :before_create_set

  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS

  # Returns user's username if the account is present in the database, else user's email is returned.
  def to_s
    account_id.present? ? account.username : email
  end

  # PRIVATE

  private

  def before_create_set
    self.role = Constants::ROLE_C if role.blank?
    self.status = Constants::STATUS_A if status.blank?
    self.invited_at = Time.now
    true
  end
end
