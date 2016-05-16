require "rails_helper"

RSpec.describe Core::TimeAggregation, type: :model do
  context 'GOOGLE ANALYTICS query string' do
    it "should return a proper quarterly query" do
      string = Core::TimeAggregation.fetch_aggregation_value("quarterly", "2016", "1")
      expect(string).to eq('2016_Q1')
    end

    it "should return a proper monthly query" do
      string = Core::TimeAggregation.fetch_aggregation_value("monthly", "2016", "2")
      expect(string).to eq("2016_February")
    end

     it "should return a proper half_yearly query" do
      string = Core::TimeAggregation.fetch_aggregation_value("half_yearly", "2016", "1")
      expect(string).to eq("2016_H1")
    end

     it "should return a proper yearly query" do
      string = Core::TimeAggregation.fetch_aggregation_value("yearly", "2016", "1")
      expect(string).to eq("2016")
    end
  end

  context '#create_time_aggregations' do
    it 'should create a new Core::TimeAggregation object and save it' do

      parent_type = 'TestImpl:TestOutput'
      parent_id = -1
      metric = "pageviews"
      aggregation_level = "monthly"
      data = []

      d = Hash.new
      d["pageviews"] = "12345.1234"
      d["month"] = 1
      d["year"] = 2016

      data.push(d)

      previous = Core::TimeAggregation.where(parent_type: parent_type, parent_id: parent_id, metric: metric, aggregation_level: aggregation_level).first
      expect(previous).to eq(nil)

      new_row = Core::TimeAggregation.create_time_aggregations(parent_type, parent_id, data, metric, aggregation_level)

      previous = Core::TimeAggregation.where(parent_type: parent_type, parent_id: parent_id, metric: metric, aggregation_level: aggregation_level).first
      expect(previous.id.class).to eq(Fixnum)

      expect(new_row).to eq(data)
      previous.delete
    end
  end

  # context '#create_aggregations' do
  #   it 'should create a new Core::Aggregation and save it' do

  #     data = [{"pageviews" => "123.231", "month" => "02", "year" => "01", "digital_object" => "This is a sample text."}]
  #     aggregation_level = "monthly"
  #     parent_id = -1
  #     parent_type = 'TestImpl:TestOutput'
  #     metric = 'pageviews'
  #     output_type = "digital_object"

  #     impl_op = Impl::Output.where(impl_parent_id: parent_id, impl_parent_type: parent_type, genre: output_type, key: output_type, value: data[output_type]).first
  #     expect(impl_op).to eq(nil)

  #     new_row = Core::TimeAggregation.create_aggregations(data, aggregation_level, parent_id, parent_type, metric, output_type)

  #     impl_op = Impl::Output.where(impl_parent_id: parent_id, impl_parent_type: parent_type, genre: output_type, key: output_type, value: data[output_type]).first
  #     expect(impl_op.id.class).to eq(Fixnum)

  #     previous = Core::TimeAggregation.where(parent_type: parent_type, parent_id: parent_id, metric: metric, aggregation_level: aggregation_level).first
  #     expect(previous.id.class).to eq(Fixnum)

  #     expect(new_row).to eq(data)
  #     impl_op.delete
  #     previous.delete
  #   end
  # end



end