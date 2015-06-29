# == Schema Information
#
# Table name: core_account_emails
#
#  id                 :integer          not null, primary key
#  account_id         :integer
#  email              :string
#  confirmation_token :string
#  confirmed_at       :datetime
#  is_primary         :boolean
#  created_by         :integer
#  updated_by         :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Core::AccountEmail < ActiveRecord::Base
  #GEMS
  self.table_name = "core_account_emails"
  include WhoDidIt
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account,class_name: "Account", foreign_key: "account_id"
  has_many :core_permissions,class_name: "Core::Permission", foreign_key: "email", primary_key: "email" #DONE no dependent_destroy
  
  #VALIDATIONS
  validates :email, presence: true, format: {with: Constants::EMAIL}, uniqueness: { :case_sensitive => false}
  validates :account_id, presence: true

  #CALLBACKS
  before_create :before_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private

  def before_create_set
    if self.is_primary.blank?
      self.confirmation_token = SecureRandom.hex(10)
      self.is_primary = false
    end
    return true
  end

end
