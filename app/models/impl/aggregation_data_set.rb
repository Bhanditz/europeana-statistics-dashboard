# frozen_string_literal: true
# == Schema Information
#
# Table name: impl_aggregation_data_sets
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  impl_data_set_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::AggregationDataSet < ActiveRecord::Base
  # GEMS
  self.table_name = 'impl_aggregation_data_sets'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  belongs_to :impl_aggregation, class_name: 'Impl::Aggregation', foreign_key: 'impl_aggregation_id'
  belongs_to :impl_data_set, class_name: 'Impl::DataSet', foreign_key: 'impl_data_set_id'
  # VALIDATIONS
  validates :impl_data_set_id, presence: :true
  validates :impl_aggregation_id, presence: :true, uniqueness: { scope: :impl_data_set_id }

  # CALLBACKS
  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS

  # Either creates a new Impl::AggregationDataSet or returns an existing
  # Impl::AggregationDataSet object from the database.
  #
  # @param impl_aggregation_identifier [String] id of the aggregation.
  # @param impl_data_set_identifier [String] id of the data set.
  # @return [Object] a reference to Impl::AggregationDataSet
  def self.find_or_create(impl_aggregation_identifier, impl_data_set_identifier)
    a = where(impl_aggregation_id: impl_aggregation_identifier, impl_data_set_id: impl_data_set_identifier).first
    if a.blank?
      a = new(impl_aggregation_id: impl_aggregation_identifier, impl_data_set_id: impl_data_set_identifier)
      a.save!
    end
    a
  end
  # PRIVATE
end
