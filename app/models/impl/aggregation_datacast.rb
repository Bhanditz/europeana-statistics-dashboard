# == Schema Information
#
# Table name: impl_aggregation_datacasts
#
#  id                       :integer          not null, primary key
#  impl_aggregation_id      :integer
#  core_datacast_identifier :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Impl::AggregationDatacast < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregation_datacasts"

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  belongs_to :core_datacast, class_name: "Core::Datacast", foreign_key: "core_datacast_identifier", primary_key: "identifier"
  #VALIDATIONS
  validates :impl_aggregation_id, presence: true
  validates :core_datacast_identifier, presence: true, uniqueness: true

  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS

  # Either creates a new Impl::AggregationDatacast or returns an existing Impl::AggregationDatacast object from the database.
  #
  # @param impl_aggregation_id [Fixnum] id of the reference Impl::Aggregation object.
  # @param core_datacast_identifier [String] a securehex string.
  # @return [Object] a reference to Impl::AggregationDatacast
  def self.find_or_create(impl_aggregation_id, core_datacast_identifier)
    a = where(impl_aggregation_id: impl_aggregation_id, core_datacast_identifier: core_datacast_identifier).first
    if a.blank?
      a = new({impl_aggregation_id: impl_aggregation_id, core_datacast_identifier: core_datacast_identifier})
      a.id = Impl::AggregationDatacast.last.present? ? Impl::AggregationDatacast.last.id + 1 : 1
    end
    a
  end

  #PRIVATE
end
