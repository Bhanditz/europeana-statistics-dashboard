# == Schema Information
#
# Table name: core_referral_gifts
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  project_id  :integer
#  referral_id :integer
#  created_by  :integer
#  updated_by  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Core::ReferralGift < ActiveRecord::Base
  #GEMS
  self.table_name = "core_referral_gifts"
  include WhoDidIt
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account, class_name: "Account", foreign_key: "account_id"
  belongs_to :core_refferal, class_name: "Core::Referral", foreign_key: "referral_id"
  belongs_to :project, class_name: "Core::Project", foreign_key: "project_id"
  
  #VALIDATIONS
  validates :account_id, presence: true
  validates :referral_id, presence: true
  #validates :project_id, presence: true, on: :update
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
end
