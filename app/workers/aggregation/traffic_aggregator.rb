class Aggregation::TrafficAggregator
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'jq'
  require 'jq/extend'

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Aggregating Traffic", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","traffic")
      aggregation_output.update_attributes(status: "Aggregating Traffic", error_messages: nil)
      begin
        impl_provider_outputs = aggregation.impl_provider_outputs.traffic
        traffic_data_output = []
        impl_provider_outputs.each {|output| traffic_data_output += JSON.parse(output.output)}
        traffic_data_with_keys = {}
        traffic_data = []

        traffic_data_output.each do |output|
          key = "#{output["year"]}<_>#{output["x"]}<_>#{output["group"]}"
          traffic_data_with_keys[key] = traffic_data_with_keys.has_key?(key) ? traffic_data_with_keys[key] + output["y"] :  output["y"]
        end
        traffic_data_with_keys.each {|key, value| traffic_data << {"y" => value,"year" => key.split("<_>")[0], "group" => key.split("<_>")[2],"x" =>key.split("<_>")[1]} } 
        traffic_data_to_save = traffic_data.to_json
        aggregation_output.update_attributes(output: traffic_data_to_save,status: "Processed Pageviews and Events")
        aggregation.update_attributes(status: "Processed Pageviews and Events")
      rescue => e
        aggregation_output.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
      end
    end
  end
end