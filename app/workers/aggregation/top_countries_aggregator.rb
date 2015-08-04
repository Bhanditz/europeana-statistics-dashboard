class Impl::TopCountriesAggregator
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Aggregating top 25 countries", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","top_25_countries")
      aggregation_output.update_attributes(status: "Aggregating top 25 countries", error_messages: nil)
      begin
        impl_provider_outputs = aggregation.impl_provider_outputs.top_25_countries
        top_25_countries_output = []
        impl_provider_outputs.each {|output| top_25_countries_output += JSON.parse(output.output)}
        top_25_countries_data = []
        top_25_countries_data_with_quarter = {}
        year_quarter_aggregated_data = {}
        top_25_countries_output.each do |output|
          key = "#{output["year"]}<_>#{output["quarter"]}"
          unless top_25_countries_data_with_quarter.has_key?(key)
            top_25_countries_data_with_quarter[key] = {}
          end
          top_25_countries_data_with_quarter[key]["#{output["country"]}<_>#{output["code"]}"] =  (top_25_countries_data_with_quarter.has_key?(key) && top_25_countries_data_with_quarter[key].has_key?("#{output["country"]}<_>#{output["code"]}")) ? top_25_countries_data_with_quarter[key]["#{output["country"]}<_>#{output["code"]}"] + output["size"].to_i :  output["size"].to_i
        end

        top_25_countries_data_with_quarter.each do |year_quarter, value|
          year, quarter = year_quarter.split("<_>")
          temp_array = []
          value.each do |country_code, value| 
            country, code = country_code.split("<_>")
            temp_array << {"year" => year, "quarter" => quarter, "country" => country,"size" => value, "code" => code}
          end
          year_quarter_aggregated_data[year_quarter] = temp_array
        end

        year_quarter_aggregated_data.each do |key,value|
          top_25_countries_data += value.first(25)
        end

        top_25_countries_data_to_save = top_25_countries_data.to_json
        aggregation_output.update_attributes(output: top_25_countries_data_to_save,status: "Processed aggregating top 25 countries")
        aggregation.update_attributes(status: "Processed aggregating top 25 countries")
      rescue => e
        aggregation_output.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to aggregate", error_messages: e.to_s)
      end
    end
  end
end