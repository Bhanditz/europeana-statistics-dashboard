# == Schema Information
#
# Table name: impl_providers
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  provider_id         :string
#  created_by          :integer
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::Provider < ActiveRecord::Base
  
  #GEMS
  self.table_name = "impl_providers"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  
  #VALIDATIONS
  validates :provider_id, presence: :true
  validates :impl_aggregation_id, presence: :true
  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
  
end
