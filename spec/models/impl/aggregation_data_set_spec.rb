# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Impl::AggregationDataSet, type: :model do
  describe '#find_or_create' do
    context 'when there is no existing AggregationDataSet' do
      it 'should return a new AggregationDataSet' do
        impl_aggregation_id = -1
        impl_data_set_id = -1
        impl_aggregation_data_set = Impl::AggregationDataSet.where(impl_aggregation_id: impl_aggregation_id, impl_data_set_id: impl_data_set_id).first
        expect(impl_aggregation_data_set).to eq(nil)

        impl_aggregation_data_set = Impl::AggregationDataSet.find_or_create(impl_aggregation_id, impl_data_set_id)
        expect(impl_aggregation_data_set).not_to eq(nil)
        expect(impl_aggregation_data_set.id.class).to eq(Fixnum)

        impl_aggregation_data_set.delete
      end
    end

    context 'when there is an existing AggregationDatacast' do
      it 'should find and return the AggregationDatacast row' do
        impl_aggregation_id = -1
        impl_data_set_id = -1
        impl_aggregation_data_set = Impl::AggregationDataSet.where(impl_aggregation_id: impl_aggregation_id, impl_data_set_id: impl_data_set_id).first
        expect(impl_aggregation_data_set).to eq(nil)

        impl_aggregation_data_set = Impl::AggregationDataSet.find_or_create(impl_aggregation_id, impl_data_set_id)
        expect(impl_aggregation_data_set).not_to eq(nil)
        expect(impl_aggregation_data_set.id.class).to eq(Fixnum)

        previous_id = impl_aggregation_data_set.id

        impl_aggregation_data_set = Impl::AggregationDataSet.find_or_create(impl_aggregation_id, impl_data_set_id)
        expect(impl_aggregation_data_set).not_to eq(nil)
        expect(impl_aggregation_data_set.id).to eq(previous_id)

        impl_aggregation_data_set.delete
      end
    end
  end
end
