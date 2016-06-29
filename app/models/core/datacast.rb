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
#  slug                   :string
#  table_name             :string
#

class Core::Datacast < ActiveRecord::Base

  self.table_name = "core_datacasts"

  #GEMS
  extend FriendlyId
  friendly_id :name, use: :slugged
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :query, :method, :refresh_frequency, :error, :fingerprint, :format, :number_of_rows, :number_of_columns

  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :core_db_connection, class_name: "Core::DbConnection", foreign_key: "core_db_connection_id"
  has_one :core_datacast_output, class_name: "Core::DatacastOutput", foreign_key: "datacast_identifier", primary_key: "identifier", dependent: :destroy
  has_many :core_vizs, class_name: "Core::Viz", foreign_key: "core_datacast_identifier", primary_key: "identifier"
  has_one :impl_aggregation_datacast, class_name: "Impl::AggregationDatacast", foreign_key: "core_datacast_identifier", primary_key: "identifier"
  has_one :impl_aggregation, through: :impl_aggregation_datacast
  #VALIDATIONS
  validates :name, presence: true
  validates :core_project_id, presence: true
  validates :core_db_connection_id, presence: true
  validates :query,presence: true
  validates :table_name,uniqueness: {scope: :core_db_connection_id}, allow_blank: true, allow_nil: true
  validates :identifier, presence: true, uniqueness: true
  validate :query_only_select

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set

  #SCOPES
  scope :top_digital_objects, -> {where("core_datacasts.name LIKE '% - Top Digital Objects'")}
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS

  # Either creates a new Core::Datacast or updates an existing Core::Datacast object in the database.
  #
  # @param q [String] SQL query string.
  # @param core_project_id [Fixnum] a reference id to Core::Project.
  # @param db_connection_id [Fixnum] a reference id to Core::DbConnection.
  # @param table_name [String] the name of table from database.
  # @return [Object] a reference to Core::Project.
  def self.create_or_update_by(q, core_project_id, db_connection_id, table_name)
    a = where(name: table_name, core_project_id: core_project_id, core_db_connection_id: db_connection_id).first
    if a.blank?
      a = new({query: q,core_project_id: core_project_id, core_db_connection_id: db_connection_id, name: table_name, identifier: SecureRandom.hex(33)})
      a.id = Core::Datacast.last.present? ? Core::Datacast.last.id + 1 : 1
      a.save
    else
      if a.query != q
        a.update_attributes(query: q)
      end
      Core::Datacast::RunWorker.perform_async(a.id) unless a.table_name.present?
    end
    a
  end


  # Retruns the frequency of occurrence of each type of data in the data passed as agrunemnts.
  #
  # @param data [Array] 2D array representation of data.
  # @return [Object] datatype [string, boolean, float, integer, date and blank] distribution for each of the column.
  def self.get_data_distribution(data)
    #Doubt: What about JSON/HSTORE datatypes
    #Data is a 2d array
    datatype_distribution = {}
    column_names = data.shift
    column_names.each do |col|
      datatype_distribution[col] = {string: 0, boolean: 0, float: 0, integer: 0, date: 0, blank: 0}
    end
    data.each do |row|
      row.each_with_index do |elem, index|
        datatype = Core::Datacast.get_element_datatype(elem)
        datatype_distribution[column_names[index]][datatype.to_sym] += 1
      end
    end
    return datatype_distribution
  end

  # Retruns the datatype of the column based datatype distribution of the the column.
  #
  # @param datatype_distribution [Object] output of Core::Datacast.get_data_distribution of a single column.
  # @return [String] the datatype of the column based on datatype distribution, possible values are float, integer, boolean, date and string.
  def self.get_col_datatype(datatype_distribution)
    datatype_distribution = datatype_distribution.reject {|_k,v| v <= 0}
    possible_types = datatype_distribution.keys
    return "float" if datatype_distribution.has_key?(:float) and (possible_types & [:date, :boolean]).length < 1 and datatype_distribution[:float] > 0
    return "integer" if datatype_distribution.has_key?(:integer) and (possible_types & [:date, :boolean, :float]).length < 1 and datatype_distribution[:integer] > 0
    return "boolean" if datatype_distribution.has_key?(:boolean) and (possible_types & [:date, :float]).length < 1 and datatype_distribution[:boolean] > 0
    return "date" if datatype_distribution.has_key?(:date) and (possible_types & [:boolean, :float, :integer]).length < 1 and datatype_distribution[:date] > 0
    return "string" if datatype_distribution.has_key?(:string) and datatype_distribution[:string] > 0
    return "string" #else - worst case scenario
  end

  # Retruns the datatype of each element in the 2D array, i.e. each value of each column.
  #
  # @param element [String] a value from the 2D array of data.
  # @return [String] the datatype of the element based on REGEX match, possible values are float, integer, boolean, date and string.
  def self.get_element_datatype(element)
    return "blank" if element.blank?
    element.strip!
    return "boolean" if ['t', 'true', 'f', 'false', 'yes', 'no', 'y', 'n'].include?(element.downcase)
    return "date" if (element.match(/^[0-3]?[0-9](-|\/)[0-1]?[0-9](-|\/)[0-9]{2,4}$/) or element.match(/^[0-1]?[0-9](-|\/)[0-3]?[0-9](-|\/)[0-9]{2,4}$/) or element.match(/^[0-3]?[0-9](-|\/)[0-1]?[0-9](-|\/)[0-9]{2,4}( |)(\s|\d(|:|\d)+)$/) or element.match(/^[0-1]?[0-9](-|\/)[0-3]?[0-9](-|\/)[0-9]{2,4}( |)(\s|\d(|:|\d)+)$/)) and Date.parse(element).present?
    return "float" if element.match(/^[-+]?[0-9]*\.[0-9]+$/)
    return "integer" if  element.match(/^[-+]?[0-9]+$/)
    return "string"
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  # Retruns the result of a SQL query in the format specified format.
  #
  # @param format [String] the format of the resultant query data, possible values ['json', '2darray', 'xml', 'raw'].
  # @return [Object] metadata of data along with data as an object same as Core::Adapters::Db.run.
  def run(format=nil)
    Core::Adapters::Db.run(self.core_db_connection, self.query, format || self.format)
  end

  # Determines whether the SQL query is a SELECT query or not.
  #
  # @return [Boolean] true if the query is a simple SQL SELECT query else it returns false..
  def query_only_select
    if self.query.downcase.index("select") != 0
      self.errors.add(:query,"Illegal query")
      return false
    end
    ["update","drop","truncate","union","insert", "db_connections"].each do |black_word|
      if self.query.downcase.include?(black_word)
        self.errors.add(:query,"Illegal query")
        return false;
      end
    end
    return true
  end

  #PRIVATE

  private

  def before_create_set
    self.number_of_rows = 0
    self.method = "get"
    self.error = ""
    self.format = "json" if self.format.nil?
    self.refresh_frequency = "0" if self.refresh_frequency.nil?
    true
  end

  def after_create_set
    c = Core::DatacastOutput.new(datacast_identifier: self.identifier)
    c.id = Core::DatacastOutput.last.present? ? Core::DatacastOutput.last.id + 1 : 1
    c.save
    unless self.table_name.present?
      Core::Datacast::RunWorker.perform_async(self.id)
    end
    true
  end
end