# frozen_string_literal: true
# == Schema Information
#
# Table name: core_projects
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  slug       :string
#  properties :hstore
#  is_public  :boolean
#  created_at :datetime
#  updated_at :datetime
#  created_by :integer
#  updated_by :integer
#

class Core::Project < ActiveRecord::Base
  # GEMS
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :account
  self.table_name = 'core_projects'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  store_accessor :properties, :description

  # ASSOCIATIONS
  belongs_to :account
  has_many :vizs, foreign_key: 'core_project_id'
  # DONE
  has_many :impl_aggregations, class_name: 'Impl::Aggregation', foreign_key: 'core_project_id'
  has_many :core_permissions, class_name: 'Core::Permission', foreign_key: 'core_project_id'
  has_many :core_db_connections, class_name: 'Core::DbConnection', foreign_key: 'core_project_id', dependent: :destroy
  has_many :core_datacasts, class_name: 'Core::Datacast', foreign_key: 'core_project_id', dependent: :destroy
  has_many :impl_reports, class_name: 'Impl::Report', foreign_key: 'core_project_id', dependent: :destroy
  # VALIDATIONS
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :account_id, presence: true

  # CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  before_destroy :on_delete

  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS

  # Returns the name of the project.
  def to_s
    name
  end

  # PRIVATE
  private

  def before_create_set
    self.properties = '{}' if properties.blank?
    self.is_public  = true
    true
  end

  def after_create_set
    Core::Permission.create(account_id: account_id, role: Constants::ROLE_O, email: account.email, status: Constants::STATUS_A, core_project_id: id)
    true
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def on_delete
    vizs.each(&:destroy)
    core_permissions.destroy_all
    true
  rescue StandardError => e
    errors.add(:name, e.to_s)
    false
  end
end
