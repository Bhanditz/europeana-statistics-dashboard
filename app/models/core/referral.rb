# == Schema Information
#
# Table name: core_referrals
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  account_id   :integer
#  referered_id :integer
#  is_eligible  :boolean
#  notes        :text
#  created_by   :integer
#  updated_by   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Core::Referral < ActiveRecord::Base
  
  #GEMS
  self.table_name = "core_referrals"
  include WhoDidIt
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :friend, class_name: "Account", foreign_key: "referered_id"
  belongs_to :referrer, class_name: "Account", foreign_key: "account_id"
  has_one :core_referral_gift, class_name: "Core::ReferralGift", foreign_key: "referral_id"
  
  #VALIDATIONS
  #CALLBACKS
  after_create :after_create_set
  
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
  
  def after_create_set
    Core::ReferralGift.create({account_id: self.account_id, referral_id: self.id})
    true
  end
  
end
