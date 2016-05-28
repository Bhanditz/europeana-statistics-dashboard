require "rails_helper"

RSpec.describe Impl::BlacklistDataset, type: :model do
  context '#get_blacklist_datasets' do
    it "should return a BlacklistDataset" do
      blacklist_dataset = Impl::BlacklistDataset.get_blacklist_datasets
      expect(blacklist_dataset.count).to eq(5)
    end
  end
end