# == Schema Information
#
# Table name: core_datacast_pulls
#
#  id                    :integer          not null, primary key
#  core_project_id       :integer
#  file_url              :text
#  first_row_header      :boolean
#  status                :string
#  error_messages        :text
#  created_by            :integer
#  updated_by            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  core_db_connection_id :integer
#  table_name            :string
#

class Core::DatacastPull < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_datacast_pulls"
  include WhoDidIt
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  
  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :core_db_connection_id, presence: true
  validates :file_url, presence: true, format: {with: Constants::URL}
  validates :first_row_header, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def to_s
    ""
  end
  
  #private
  private
  
  def before_create_set
    self.status = "<span style='color:orangered;'>Pending..</span>"
    true
  end
  
end
