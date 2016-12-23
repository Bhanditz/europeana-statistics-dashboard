# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Impl::DataSet, type: :model do
  context '#get_access_token' do
    it 'should return a access token' do
      expect(Impl::DataSet.get_access_token).not_to eq(nil)
    end
  end

  context '#find_or_create' do
    it 'should create a new dataset' do
      test_data = Impl::DataSet.where(name: 'TestDataSet').first
      expect(test_data).to eq(nil)

      test_data = Impl::DataSet.find_or_create('TestDataSet')
      expect(test_data.id.class).to eq(Fixnum)
    end

    it 'should return a row from database' do
      test_name = Impl::DataSet.last.name
      test_data_set = Impl::DataSet.find_or_create(test_name)
      expect(test_data_set).not_to eq(nil)
      expect(test_data_set.id.class).to eq(Fixnum)
    end
  end
end
