# == Schema Information
#
# Table name: core_tokens
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  core_project_id :integer
#  api_token       :string(255)
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  created_by      :integer
#  updated_by      :integer
#

class Core::Token < ActiveRecord::Base
  #Gems
  self.table_name = "core_tokens"
  include WhoDidIt
  include WhoDidItProject
  
  #CONSTANTS  
  #ATTRIBUTES
  #ACCESSORS

  #ASSOCIATIONS
  belongs_to :account
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"

  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :core_project_id, presence: true
  validates :account_id, presence: true
  
  #CALLBACKS
  before_create :before_create_set

  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS

  def to_s
    self.name
  end

  #PRIVATE
  
  private
  
  def before_create_set
    self.api_token = SecureRandom.hex(18)
    true
  end

end
