# frozen_string_literal: true
require 'rails_helper'
require 'pg'
RSpec.describe Core::DataTransform, type: :model do
  before(:each) do
    @PGconnection = PGconn.open(dbname: 'europeana_stats_test')
  end

  context 'Convert Postgres object to ' do
    it '2D array' do
      query = @PGconnection.exec('SELECT * FROM generate_series(2,4);')
      output = Core::DataTransform.twod_array_generate(query)
      expected_output = [['generate_series'], ['2'], ['3'], ['4']]
      expect(output).to eq(expected_output)
    end

    it 'JSON Object' do
      query = @PGconnection.exec('SELECT * FROM generate_series(2,4);')
      output = Core::DataTransform.json_generate(query)
      expected_output = '[{"generate_series":"2"},{"generate_series":"3"},{"generate_series":"4"}]'
      expect(output).to eq(expected_output)
    end

    it 'XML Object' do
      query = @PGconnection.exec('SELECT * FROM generate_series(2,4);')
      output = Core::DataTransform.json_generate(query, true)
      expected_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<objects type=\"array\">\n  <object>\n    <generate-series>2</generate-series>\n  </object>\n  <object>\n    <generate-series>3</generate-series>\n  </object>\n  <object>\n    <generate-series>4</generate-series>\n  </object>\n</objects>\n"
      expect(output).to eq(expected_output)
    end

    it 'csv output' do
      query = @PGconnection.exec('SELECT * FROM generate_series(2,4) as A, generate_series(1,3) as B;')
      output = Core::DataTransform.csv_generate(query)
      expected_output = "a,b\n2,1\n2,2\n2,3\n3,1\n3,2\n3,3\n4,1\n4,2\n4,3"
      expect(output).to eq(expected_output)
    end
  end
end
