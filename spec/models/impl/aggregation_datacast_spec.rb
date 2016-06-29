require "rails_helper"

RSpec.describe Impl::AggregationDatacast, type: :model do
  context '#find_or_create' do
    it "should return a new AggregationDatacast" do

      impl_aggregation_id = -1
      core_datacast_identifier = SecureRandom.hex(33)

      impl_datacast = Impl::AggregationDatacast.where(impl_aggregation_id: impl_aggregation_id, core_datacast_identifier: core_datacast_identifier).first
      expect(impl_datacast).to eq(nil)

      impl_datacast = Impl::AggregationDatacast.find_or_create(impl_aggregation_id, core_datacast_identifier)
      expect(impl_datacast).not_to eq(nil)
      expect(impl_datacast.id.class).to eq(Fixnum)

      impl_datacast.delete
    end

    it 'should find and return the AggregationDatacast row' do
      impl_aggregation_id = -1
      core_datacast_identifier = SecureRandom.hex(33)

      impl_datacast = Impl::AggregationDatacast.where(impl_aggregation_id: impl_aggregation_id, core_datacast_identifier: core_datacast_identifier).first
      expect(impl_datacast).to eq(nil)

      impl_datacast = Impl::AggregationDatacast.find_or_create(impl_aggregation_id, core_datacast_identifier)
      expect(impl_datacast).not_to eq(nil)
      expect(impl_datacast.id.class).to eq(Fixnum)

      previous_id = impl_datacast.id

      impl_datacast = Impl::AggregationDatacast.find_or_create(impl_aggregation_id, core_datacast_identifier)
      expect(impl_datacast).not_to eq(nil)
      expect(impl_datacast.id).to eq(previous_id)

      impl_datacast.delete
    end

  end
end