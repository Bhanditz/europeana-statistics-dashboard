# == Schema Information
#
# Table name: core_custom_dashboards
#
#  id              :integer          not null, primary key
#  core_project_id :integer
#  name            :string(255)
#  properties      :hstore
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  slug            :string(255)
#

class Core::CustomDashboard < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_custom_dashboards"
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :core_project
  include WhoDidIt
   
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :git_url, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count, :cdn_status, :cdn_bucket, :ssh_private_key
  
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  
  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :name, presence: true, format: {with: /(^[a-z0-9]+)(([a-z0-9]|\.)+$)/i, message: "Can include only characters, numbers and dot"}
  validates :git_url, presence: true, format: {with: Constants::GIT_URL, message: "Format should be git@domain.com:user/project.git"}
  validates :ssh_private_key, presence: true
  validate  :is_it_unique, on: :create

  #validates :cdn_bucket, uniqueness: { case_sensitive: false }, allow_blank: true, on: :create
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def to_s
    self.name
  end
  
  #PRIVATE
  
  private
  
  def before_create_set
    self.cdn_published_count = "0"
    self.cdn_status = "Preparing."
    true
  end
  
  def is_it_unique
    if Core::CustomDashboard.where(core_project_id: self.core_project_id).where("name = ? or properties -> 'git_url' = ?", self.name, self.git_url).present?
      errors.add(:git_url, "already exists")
    end
  end
  
end
