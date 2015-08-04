class Impl::TopDigitalObjectsAggregator
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Aggregating top 10 digital objects", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","top_10_digital_objects")
      aggregation_output.update_attributes(status: "Aggregating top 10 digital objects", error_messages: nil)
      begin
        impl_provider_outputs = aggregation.impl_provider_outputs.top_10_digital_objects
        top_10_digital_objects_output = []
        impl_provider_outputs.each {|output| top_10_digital_objects_output += JSON.parse(output.output)}
        top_10_digital_objects_data = []
        top_10_digital_objects_data_with_quarter = {}
        year_quarter_aggregated_data = {}
        top_10_digital_objects_output.each do |output|
          key = "#{output["year"]}<_>#{output["quarter"]}"
          unless top_10_digital_objects_data_with_quarter.has_key?(key)
            top_10_digital_objects_data_with_quarter[key] = {}
          end
          top_10_digital_objects_data_with_quarter[key]["#{output["title"]}<_>#{output["title_url"]}<_>#{output["image_url"]}"] =  (top_10_digital_objects_data_with_quarter.has_key?(key) && top_10_digital_objects_data_with_quarter[key].has_key?("#{output["title"]}<_>#{output["title_url"]}<_>#{output["image_url"]}")) ? top_10_digital_objects_data_with_quarter[key]["#{output["title"]}<_>#{output["title_url"]}<_>#{output["image_url"]}"] + output["size"].to_i :  output["size"].to_i
        end

        top_10_digital_objects_data_with_quarter.each do |year_quarter, value|
          year, quarter = year_quarter.split("<_>")
          temp_array = []
          value.each do |title_title_url_image_url, value| 
            title, title_url, image_url = title_title_url_image_url.split("<_>")
            temp_array << {"year" => year, "quarter" => quarter, "title" => title,"size" => value, "title_url" => title_url, "image_url" => image_url}
          end
          year_quarter_aggregated_data[year_quarter] = temp_array
        end

        year_quarter_aggregated_data.each do |key,value|
          top_10_digital_objects_data += value.first(25)
        end

        top_10_digital_objects_data_to_save = top_10_digital_objects_data.to_json
        aggregation_output.update_attributes(output: top_10_digital_objects_data_to_save,status: "Processed aggregating top 10 digital objects")
        aggregation.update_attributes(status: "Processed aggregating top 10 digital objects")
      rescue => e
        aggregation_output.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
      end
    end
  end
end