# == Schema Information
#
# Table name: core_data_stores
#
#  id                     :integer          not null, primary key
#  core_project_id        :integer
#  name                   :string(255)
#  slug                   :string(255)
#  properties             :hstore
#  created_at             :datetime
#  updated_at             :datetime
#  parent_id              :integer
#  clone_parent_id        :integer
#  table_name             :string(255)
#  created_by             :integer
#  updated_by             :integer
#  genre_class            :string(255)
#  is_verified_dictionary :boolean
#  join_query             :json
#  meta_description       :text
#

class Core::DataStore < ActiveRecord::Base
  #GEMS
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :core_project
  self.table_name = "core_data_stores"
  include WhoDidIt
   
  
   

  #CONSTANTS
  #ATTRIBUTES  
  #ACCESSORS
  #serialize :properties, ActiveRecord::Coders::Hstore

  attr_accessor :clone_to_core_project_id, :append_data_store_id
  store_accessor :properties, :source, :genre, :commit_message, :clone_count,
                 :worker_error, :worker_status, :size, :notes, :source, :license,
                 :publisher, :source_url, :contributor, :description, :time_series_granularity, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count, :marked_to_be_deleted

  
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :parent, class_name: "Core::DataStore", foreign_key: "parent_id"
  belongs_to :clone_parent, class_name: "Core::DataStore", foreign_key: "clone_parent_id"
  has_one :account, through: :core_project
  has_many :vizs, class_name: "Core::Viz", foreign_key: "core_data_store_id" #dependent: :destroy PURPOSELY STOPPED
  
  #VALIDATIONS
  validates :name, presence: true
  validates :core_project_id, presence: true
  validates :source_url, format: {with: Constants::URL}, allow_blank: true
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  
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
  
  def is_joined_dataset?
    self.join_query.present?
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
  
  def self.upload_or_create_file(file_path, file_name, _core_project_id, first_row_header, column_separator, token)
    d = Core::DataStore.new({name: file_name, core_project_id: _core_project_id})
    if d.save
      grid_data = []
      is_everything_saved_properly = false
      begin
        CSV.foreach(file_path, {:col_sep => column_separator, :skip_blanks => true}) do |row|
          grid_data << row
          if $. == 2
            is_everything_saved_properly = Core::DataStore.create_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data, first_row_header)
            break if !is_everything_saved_properly
            grid_data = []
          elsif $. % 100 == 0 and $. > 0
            is_everything_saved_properly = Core::DataStore.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
            break if !is_everything_saved_properly
            grid_data = []
          end
        end
        if !grid_data.empty?
          is_everything_saved_properly = Core::DataStore.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
        end
      rescue
        is_everything_saved_properly = false
      end
      if is_everything_saved_properly
        return d
      else
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
  
  def increase_clone_count
    self.update_attributes(clone_count: self.clone_count.blank? ? 1 : 1 + self.clone_count.to_i)
  end
  
  def create_clone(table_name, cloned_project_id)
    return Core::DataStore.create(core_project_id: cloned_project_id, name: self.name, properties: self.properties, clone_parent_id: self.id, table_name: table_name)
  end
  
  def to_s
    self.name
  end
  
  def children
    Core::DataStore.where(parent_id: self.id)
  end
  
  def clone_countz
    self.properties["clone_count"].blank? ? 0 : self.properties["clone_count"]
  end
  
  #----------------- PUBLISH TO CDN Functionality ------------------------------
  
  def s3_url
    self.cdn_published_url
  end
  
  def s3_file_name
    self.account.slug + "/" + self.core_project.slug + "/datasets/" + self.slug + ".csv"
  end

  def generate_file_in_tmp(export_file_name,api_token)
    config = {}
    config["mode"] = "select"
    config["select"] = []
    config["limit"] = 2000
    config["offset"] = 0
    headers_added = false
    File.open(export_file_name, "w+") do |f|
      row_length = 0
      loop do
        grid_data = Nestful.post REST_API_ENDPOINT + "#{self.account.slug}/#{self.core_project.slug}/#{self.slug}/filter/show", {:config => config ,token: api_token}
        count = 0
        
        grid_data = grid_data["data"]
        #remove first row if headers added to avoid duplication of headers
        grid_data.shift if headers_added
        grid_data.each do |row|
          if count == 0 and not headers_added 
            row_length = row.length - 1 #subtracting 1 to match with index.
            headers_added = true
          end
          row.each_with_index do |col_value, index|
            if col_value.present?
              col_value.gsub! "\"", "'" if col_value.include? "\"" #check if string col has "
              col_value = "\"" + col_value + "\"" if col_value.include? "," #check if col has ,
            end
            f.write(col_value)
            f.write(",") if index != row_length               
          end
          f.write("\n")
          count += 1
        end
        if count < 2000
          break
        else
          config["offset"] += 2000
        end
      end #end loop
    end #end file open
    File.chmod(0777,export_file_name)
  end
  
  #----------------- PUBLISH TO CDN Functionality ------------------------------

  #FUNCTIONS
    
  def delete_str
    self.name
  end

  def check_dependent_destroy?
    is_deletable = true
    dependent_to_destroy = ""
    if self.vizs.present?
      is_deletable = false
      dependent_to_destroy = "visualizations"
    end
    return {is_deletable: is_deletable,dependent_to_destroy: dependent_to_destroy}
  end

  #PRIVATE
  private
  
  def before_create_set
    self.properties = "{}" if self.properties.blank?
    self.properties["commit_message"] = "First Commit"
    self.properties["genre"] = "csv"
    self.properties["clone_count"] = "0"
    self.cdn_published_count = "0"
    self.cdn_published_url = ""
    self.cdn_published_at = ""
    self.cdn_published_error = ""
    self.table_name = (0...32).map { (65 + rand(26)).chr }.join.downcase! if self.table_name.blank?
    self.genre_class = "dataset"
    self.marked_to_be_deleted = "false"
    true
  end
  
  def is_csv?
    (self.core_query_id.blank? and self.parent_id.blank? and self.genre == "csv") ? true : false
  end
  
  def should_generate_new_friendly_id?
    name_changed?
  end

  def on_delete
    #delete data from rumi_datasets(api db)
    #@data_store.viz.delete_all
    #remove data from s3/object storage
  end
  
end
