# == Schema Information
#
# Table name: core_themes
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  sort_order :integer
#  config     :json
#  image_url  :text
#  created_by :integer
#  updated_by :integer
#  created_at :datetime
#  updated_at :datetime
#

class Core::Theme < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_themes"
  include WhoDidIt
   
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account
  
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :account_id}
  validates :config, presence: true
  #ideally we should write a validation that if user creates a theme then account_id is mandatory
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  scope :admin, -> {where("account_id IS NULL")}
  default_scope {order('sort_order ASC')}
  
  #CUSTOM SCOPES
  #FUNCTIONS

  def to_s
    self.name
  end
  
  #PRIVATE
  private
  
  def before_create_set
    if self.account_id.present?
      self.sort_order = 0
      self.image_url = "https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/themes/custom-theme-icon.png"
    end
    true
  end
  
end
