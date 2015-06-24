# == Schema Information
#
# Table name: core_account_images
#
#  id         :integer          not null, primary key
#  account_id :integer
#  filetype   :string(255)
#  image_url  :text
#  filesize   :string(255)
#  created_by :integer
#  updated_by :integer
#  created_at :datetime
#  updated_at :datetime
#  properties :hstore
#

class Core::AccountImage < ActiveRecord::Base
  #GEMS
  self.table_name = "core_account_images"
  include WhoDidIt
  include WhoDidItOrganisation
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :base_url,:marked_to_be_deleted
  #ASSOCIATIONS
  belongs_to :account,class_name: "Account", foreign_key: "account_id"
  
  #VALIDATIONS
  validates :account_id, presence: true
  validates :image_url, presence: true
  validate  :validate_filesize
  mount_uploader :image_url, ImageUrlUploader

  #CALLBACKS
  before_create :before_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def validate_filesize
    if (self.image_url.size.to_f/1000).round(2) > 200
      self.errors.add(:filesize,"maximum 200 KB allowed")
    end
  end

  def thumb_url
    "#{self.base_url}_thumb.#{self.filetype}"
  end

  def dp_url
    "#{self.base_url}_dp.#{self.filetype}"
  end

  def original_url
    "#{self.base_url}_original.#{self.filetype}"
  end

  #PRIVATE
  private

  def before_create_set
    self.filesize = (self.image_url.size.to_f/1000).round(2)
    self.marked_to_be_deleted = "false"
    true
  end
end
