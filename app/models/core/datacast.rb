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
  include WhoDidIt
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
  scope :ready, ->{where("properties->'error' != ?","''").where.not(last_run_at: nil)}
  scope :media_type, -> {where("core_datacasts.name LIKE '%Media Types'")}
  scope :reusable, -> {where("core_datacasts.name LIKE '%Reusables'")}
  scope :traffic, -> {where("core_datacasts.name LIKE '%Traffic'")}
  scope :top_country, -> {where("core_datacasts.name LIKE '%Top Countries'")}
  scope :top_digital_objects, -> {where("core_datacasts.name LIKE '%Top Digital Objects'")}
  scope :collections, -> {where("core_datacasts.name LIKE '%Collections'")}
  scope :line_charts, -> {where("core_datacasts.name LIKE '%Line Chart'")}

  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
  def self.create_or_update_by(q,core_project_id,db_connection_id,table_name)
    a = where(name: table_name, core_project_id: core_project_id, core_db_connection_id: db_connection_id).first
    if a.blank?
      a = create({query: q,core_project_id: core_project_id, core_db_connection_id: db_connection_id, name: table_name, identifier: SecureRandom.hex(33)})
    else
      if a.query != q
        a.update_attributes(query: q)
        Core::Datacast::RunWorker.perform_async(a.id) unless a.table_name.present?
      end
    end
    a
  end

  def self.get_data_distribution(data)
    #Doubt: What about JSON/HSTORE datatypes
    #Data is a 2d array
    datatype_distribution = {}
    column_names = data.shift
    column_names.each do |col|
      datatype_distribution[col] = {"string": 0, "boolean": 0, "float": 0, "integer": 0, "date": 0, "blank": 0}
    end
    data.each do |row|
      row.each_with_index do |elem, index|
        datatype = Core::Datacast.get_element_datatype(elem)
        datatype_distribution[column_names[index]][datatype.to_sym] += 1
      end
    end
    return datatype_distribution
  end

  def self.get_col_datatype(datatype_distribution)
    datatype_distribution = datatype_distribution.reject {|k,v| v <= 0}
    possible_types = datatype_distribution.keys
    return "float" if datatype_distribution.has_key?(:float) and (possible_types & [:date, :boolean]).length < 1 and datatype_distribution[:float] > 0
    return "integer" if datatype_distribution.has_key?(:integer) and (possible_types & [:date, :boolean, :float]).length < 1 and datatype_distribution[:integer] > 0
    return "boolean" if datatype_distribution.has_key?(:boolean) and (possible_types & [:date, :float]).length < 1 and datatype_distribution[:boolean] > 0
    return "date" if datatype_distribution.has_key?(:date) and (possible_types & [:boolean, :float, :integer]).length < 1 and datatype_distribution[:date] > 0
    return "string" if datatype_distribution.has_key?(:string) and datatype_distribution[:string] > 0
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


  def self.create_grid(projectname, username, filename, token, grid_data, first_row_header=true)
    begin
      response = Nestful.post REST_API_ENDPOINT + "#{username}/#{projectname}/#{filename}/grid/create", {:token => token, :data => grid_data, :first_row_header => first_row_header }, :format => :json
      if response.status == 201
        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end
  
  def self.upload_tmp_file(_data)
    uploader = CsvFileUploader.new
    if uploader.cache!(_data)
      file_path = uploader.file.path
      file_size = uploader.file.size
      if !file_path or file_size < 1
        return [uploader, "File is empty.", nil] 
      end
    else
      return [uploader, "File is not uploaded.", nil]
    end
    headers = File.open(file_path, &:readline) 
    begin 
      column_separator = ["\t", "|", ";", ","].sort_by{|separator| headers.count(separator)}.last
    rescue => e
      return [uploader, e.to_s, nil]
    end
    return [uploader, nil, column_separator]
  end
  
  def self.upload_or_create_file(file_path, file_name, _core_project_id,_core_db_connection_id ,table_name,first_row_header, column_separator,token)
    query = "Select * from #{table_name}"
    d = Core::Datacast.new({query: query, name: file_name, core_project_id: _core_project_id, core_db_connection_id: _core_db_connection_id, identifier: SecureRandom.hex(33), table_name: table_name })
    if d.save
      puts d.id
      grid_data = []
      is_everything_saved_properly = false
      begin
        CSV.foreach(file_path, {:col_sep => column_separator, :skip_blanks => true}) do |row|
          grid_data << row
          if $. == 2
            is_everything_saved_properly = Core::Datacast.create_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data, first_row_header)
            break if !is_everything_saved_properly
            grid_data = []
          elsif $. % 100 == 0 and $. > 0
            is_everything_saved_properly = Core::Datacast.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
            break if !is_everything_saved_properly
            grid_data = []
          end
        end
        if !grid_data.empty?
          is_everything_saved_properly = Core::Datacast.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
        end
      rescue
        is_everything_saved_properly = false
      end
      if is_everything_saved_properly
        return d
      else
        puts d.errors.messages
        d.destroy
        return nil
      end
    else
      return nil
    end
  end
  
  def self.insert_into_grid(projectname, username, filename, token, grid_data)
    begin
      response = Nestful.post REST_API_ENDPOINT + "#{username}/#{projectname}/#{filename}/row/batch_add", {token: token, data: grid_data }, :format => :json
      if response.status == 201
        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end

  def run(format=nil)
    Core::Adapters::Db.run(self.core_db_connection, self.query, format || self.format)
  end

  def column_names(only_d_or_m=nil)
    column_names = []
    unless self.column_properties.blank?
      if only_d_or_m.nil?
        column_names = self.column_properties.keys
      else
        column_names = self.column_properties.map {|key, value| key if value["d_or_m"] == only_d_or_m }.compact!
      end
    end
    return column_names
  end

  def column_with_d_or_m(only_d_or_m=nil)
    column_names = []
    unless self.column_properties.blank?
      if only_d_or_m.nil?
        column_names = self.column_properties.map {|key, value| {key => value["d_or_m"]}}
      else
        column_names = self.column_properties.map {|key, value| {key => value["d_or_m"]} if value["d_or_m"] == only_d_or_m }.compact!
      end
    end
    return column_names
  end

  def count(d_or_m)
    dimension_or_metric = self.column_with_d_or_m.select {|k| k if k.values.first == d_or_m}
    return dimension_or_metric.count
  end

  def get_auto_html_for_number_indicators
    return "<div id='#{self.identifier}' data-datacast_identifier='#{self.identifier}' class='card_with_value' ></div>"
  end

  def get_auto_html_for_table
    return "<div id='#{self.identifier}' data-datacast_identifier='#{self.identifier}' class='box_table' ></div>"
  end

  def query_only_select
    if self.query.index("Select") != 0
      self.errors.add(:query,"Illegal query")
      return false
    end
    ["update","drop","truncate","union","insert"].each do |black_word|
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
    Core::DatacastOutput.create(datacast_identifier: self.identifier, core_datacast_id: self.id)
    unless self.table_name.present?
      Core::Datacast::RunWorker.perform_at(10.second.from_now,self.id)
    end
    true
  end

end