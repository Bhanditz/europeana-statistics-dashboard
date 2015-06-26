# == Schema Information
#
# Table name: core_datacasts
#
#  id                     :integer          not null, primary key
#  core_project_id        :integer
#  core_db_connection_id  :integer
#  name                   :string
#  identifier             :string
#  properties             :hstore
#  created_by             :integer
#  updated_by             :integer
#  created_at             :datetime
#  updated_at             :datetime
#  params_object          :json             default({})
#  column_properties      :json             default({})
#  last_run_at            :datetime
#  last_data_changed_at   :datetime
#  count_of_queries       :integer
#  average_execution_time :float
#  size                   :float
#

class Core::Datacast < ActiveRecord::Base
  
  self.table_name = "core_datacasts"

  #GEMS
  include WhoDidIt
  #CONSTANTS
  #ATTRIBUTES  
  #ACCESSORS
  store_accessor :properties, :query, :method, :refresh_frequency, :error, :fingerprint, :format

  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :core_db_connection, class_name: "Core::DbConnection", foreign_key: "core_db_connection_id"
  
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :core_project_id, presence: true
  validates :core_db_connection_id, presence: true
  validates :query,presence: true
  validates :identifier, presence: true, uniqueness: true

  #CALLBACKS
  before_create :before_create_set
  #after_create :after_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
  def self.create_or_update_by(q,core_project_id,db_connection_id,table_name,column_properties)
    a = where(name: table_name, core_project_id: core_project_id, core_db_connection_id: db_connection_id).first
    if a.blank?
      create({query: q,core_project_id: core_project_id, core_db_connection_id: db_connection_id, name: table_name, column_properties: column_properties})
    else
      a.update_attributes(query: q, column_properties: column_properties)
    end
    a
  end
  #PRIVATE
  
  private
  
  def before_create_set
    self.identifier = SecureRandom.hex(33)
    true
  end

  def after_create_set
    true
  end

end
