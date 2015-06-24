# == Schema Information
#
# Table name: core_map_files
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  is_public   :boolean
#  name        :string(255)
#  size        :string(255)
#  filetype    :string(255)
#  properties  :hstore
#  is_verified :boolean
#  created_by  :integer
#  updated_by  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Core::MapFile < ActiveRecord::Base
  #GEMS
  self.table_name = "core_map_files"
  include WhoDidIt
   
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count
  attr_accessor :file
  #ASSOCIATIONS
  belongs_to :account
  has_many :downloads, class_name: "Core::SessionImpl",foreign_key: "core_map_file_id", dependent: :destroy

  #VALIDATIONS
  validates :account_id, presence: true
  validates :name, presence: true,uniqueness: {scope: :account_id}
  validates :filetype,presence: true
  validate :filetype_belonging_to_valid_extension, on: :create

  #CALLBACKS
  before_create :before_create_set
  before_update :before_save_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def filetype_belonging_to_valid_extension
    if self.filetype.present?
      file_type = self.filetype.split(".")[-1]
      unless ["geojson","kml","topojson"].include?file_type
        errors.add(:filetype,"Invalid. Only Files with extention .geojson or .topojson are allowed")
      end
    end
  end
  
  def to_s
    self.name
  end

  def is_used
    false
  end
  #PRIVATE

  def before_create_set
    self.is_verified = false
    if self.filetype.present?
      file_type = self.filetype.split(".")[-1]
      self.filetype = (file_type == "geojson") ? "GeoJson" : "TopoJson"
    end
    true
  end

  def before_save_set
    self.name = self.name.titleize
  end

end
