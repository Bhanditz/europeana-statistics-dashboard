require "rails_helper"

RSpec.describe Impl::AggregationRelation, type: :model do
  context '#create_or_find' do
    it "should return a new AggregationRelation" do
      parent_id = -1
      parent_genre = "provider"
      child_id = -1
      child_genre = "data_provider"

      impl_relation = Impl::AggregationRelation.where(impl_parent_id: parent_id, impl_child_id: child_id).first
      expect(impl_relation).to eq(nil)

      impl_relation = Impl::AggregationRelation.create_or_find(parent_id, parent_genre, child_id, child_genre)
      expect(impl_relation).not_to eq(nil)
      expect(impl_relation.id.class).to eq(Fixnum)

      impl_relation.delete
    end

    it 'should find and return the AggregationRelation row' do
      parent_id = -1
      parent_genre = "provider"
      child_id = -1
      child_genre = "data_provider"

      impl_relation = Impl::AggregationRelation.where(impl_parent_id: parent_id, impl_child_id: child_id).first
      expect(impl_relation).to eq(nil)

      impl_relation = Impl::AggregationRelation.create_or_find(parent_id, parent_genre, child_id, child_genre)
      expect(impl_relation).not_to eq(nil)
      expect(impl_relation.id.class).to eq(Fixnum)

      previous_id = impl_relation.id

      impl_relation = Impl::AggregationRelation.create_or_find(parent_id, parent_genre, child_id, child_genre)
      expect(impl_relation).not_to eq(nil)
      expect(impl_relation.id).to eq(previous_id)

      impl_relation.delete
    end
  end
end