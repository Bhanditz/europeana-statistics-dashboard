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
  store_accessor :properties, :query, :method, :refresh_frequency, :error, :fingerprint, :format, :number_of_rows, :number_of_columns

  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :core_db_connection, class_name: "Core::DbConnection", foreign_key: "core_db_connection_id"
  has_one :core_datacast_output, class_name: "Core::DatacastOutput", foreign_key: "datacast_identifier", primary_key: "identifier"
  
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :core_project_id, presence: true
  validates :core_db_connection_id, presence: true
  validates :query,presence: true
  validates :identifier, presence: true, uniqueness: true

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
  def self.create_or_update_by(q,core_project_id,db_connection_id,table_name,column_properties)
    a = where(name: table_name, core_project_id: core_project_id, core_db_connection_id: db_connection_id).first
    if a.blank?
      a = create({query: q,core_project_id: core_project_id, core_db_connection_id: db_connection_id, name: table_name, column_properties: column_properties, identifier: SecureRandom.hex(33)})
    else
      a.update_attributes(query: q, column_properties: column_properties)
    end
    a
  end

  def self.get_data_distribution(data)
    #Doubt: What about JSON/HSTORE datatypes
    datatype_distribution = {}
    column_names = data.shift
    column_names.each do |col|
      datatype_distribution[col] = {"string" => 0, "boolean" => 0, "float" => 0, "integer" => 0, "date" => 0, "blank" => 0}
    end
    data.each do |row|
      row.each_with_index do |elem, index|
        datatype = Core::Datacast.get_element_datatype(elem)
        datatype_distribution[column_names[index]][datatype] += 1
      end
    end
    return datatype_distribution
  end

  def self.get_col_datatype(col_data_distribution)
    # Need to work on it. This is scrappy's code, for reference
    # possible_types = datatype_distribution.keys
    # return "double" if datatype_distribution.has_key?("double") and (possible_types & ["date", "boolean"]).length < 1 and datatype_distribution["double"] > 0
    # return "integer" if datatype_distribution.has_key?("integer") and (possible_types & ["date", "boolean", "double"]).length < 1 and datatype_distribution["integer"] > 0
    # return "boolean" if datatype_distribution.has_key?("boolean") and (possible_types & ["date", "double"]).length < 1 and datatype_distribution["boolean"] > 0
    # return "date" if datatype_distribution.has_key?("date") and (possible_types & ["boolean", "double", "integer"]).length < 1 and datatype_distribution["date"] > 0
    # return "string" if datatype_distribution.has_key?("string") and datatype_distribution["string"] > 0
    return "string" #else - worst case scenario
  end

  def self.get_element_datatype(element)
    return "blank" if element.blank?
    element.strip!
    return "boolean" if ['t', 'true', 'f', 'false', 'yes', 'no', 'y', 'n'].include?(element.downcase)
    return "date" if (element.match(/^[0-3]?[0-9](-|\/)[0-1]?[0-9](-|\/)[0-9]{2,4}$/) or element.match(/^[0-1]?[0-9](-|\/)[0-3]?[0-9](-|\/)[0-9]{2,4}$/) or element.match(/^[0-3]?[0-9](-|\/)[0-1]?[0-9](-|\/)[0-9]{2,4}( |)(\s|\d(|:|\d)+)$/) or element.match(/^[0-1]?[0-9](-|\/)[0-3]?[0-9](-|\/)[0-9]{2,4}( |)(\s|\d(|:|\d)+)$/)) and Date.parse(element).present?
    return "float" if element.match(/^[-+]?[0-9]*\.[0-9]+$/)
    return "integer" if  element.match(/^[-+]?[0-9]+$/)
    return "string"
  end

  def run
    Core::Adapters::Db.run(self.core_db_connection, self.query, self.format)
  end
  
  #PRIVATE
  
  private
  
  def before_create_set
    self.number_of_rows = 0
    self.method = "get"
    self.error = ""
    true
  end

  def after_create_set
    Core::DatacastOutput.create(datacast_identifier: self.identifier, core_datacast_id: self.id)
    Core::Datacast::RunWorker.perform_async(self.id)
    true
  end

end
