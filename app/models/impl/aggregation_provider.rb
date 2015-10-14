# == Schema Information
#
# Table name: impl_aggregation_providers
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  impl_provider_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::AggregationProvider < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregation_providers"
  
  #CONSTANTS
  #ATTRIBUTES
  attr_accessor :provider_id
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  belongs_to :impl_provider, class_name: "Impl::Provider", foreign_key: "impl_provider_id"
  #VALIDATIONS
  validates :impl_aggregation_id, presence: true
  validates :impl_provider_id, presence: true, uniqueness: {scope: :impl_aggregation_id}
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
end
