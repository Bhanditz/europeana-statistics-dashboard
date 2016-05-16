require "rails_helper"

RSpec.describe Ref::CountryCode, type: :model do
  context 'Ref::CountryCode#find_or_create' do
    it 'should return a new row' do
      previous_row = Ref::CountryCode.where(code: 'test_code', country: 'TEST_COUNTRY').first
      new_row = Ref::CountryCode.find_or_create('test_code', 'TEST_COUNTRY')
      expect(previous_row).to eq(nil)
      expect(new_row.id.class).to eq(Fixnum)
      new_row.delete
    end

    it 'should return alreay created row' do
      previous_row = Ref::CountryCode.find_or_create('test_code', 'TEST_COUNTRY')
      new_row = Ref::CountryCode.find_or_create('test_code', 'TEST_COUNTRY')
      expect(previous_row.id).to eq(new_row.id)
      previous_row.delete
    end

  end


end