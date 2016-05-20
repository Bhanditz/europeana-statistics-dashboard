require "rails_helper"

RSpec.describe Core::Datacast, type: :model do
  context 'Postgresql helper methods for models' do
    it 'should return query to get all columns for tablename' do
      query = Core::Adapters::Pg.query_get_all_columns('test')
      expect(query).to eq("SELECT column_name, data_type from information_schema.columns where table_name='test';")
    end
  end
end