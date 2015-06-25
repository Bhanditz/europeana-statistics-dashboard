# == Schema Information
#
# Table name: core_datacasts
#
#  id                    :integer          not null, primary key
#  core_project_id       :integer
#  core_db_connection_id :integer
#  name                  :string
#  identifier            :string
#  properties            :hstore
#  created_by            :integer
#  updated_by            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  params_object         :json             default({})
#

class Core::Datacast < ActiveRecord::Base
  
  self.table_name = "core_datacasts"

  #GEMS
  include WhoDidIt
  #CONSTANTS
  #ATTRIBUTES  
  #ACCESSORS
  store_accessor :properties, :query, :method, :refresh_frequency, :caching_method, :error, :fingerprint, :count_of_queries, :last_execution_time, :average_execution_time, :size, :cdn_source, :cdn_published_url, :format

  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :core_db_connection, class_name: "Core::DbConnection", foreign_key: "core_db_connection_id"
  
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :core_project_id, presence: true
  validates :core_db_connection_id, presence: true
  validates :query,presence: true

  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
  #PRIVATE
  
  private
  
  def before_create_set
    self.identifier = SecureRandom.hex(33)
    true
  end

end
