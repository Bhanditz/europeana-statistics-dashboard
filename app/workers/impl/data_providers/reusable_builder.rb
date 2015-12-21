class Impl::DataProviders::ReusableBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if  ["country","provider","data_provider","europeana"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Reusables", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","reusable")
      aggregation_output.update_attributes(status: "Building Reusables", error_messages: nil)
      begin
        europeana_query = aggregation.europeana? ? "*:*" : CGI.escape("#{aggregation.genre.upcase}:\"#{(aggregation.name)}\"")
        reusables = Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{europeana_query}&facet=REUSABILITY&profile=facets&rows=0")
        if reusables["facets"].present? and reusables["facets"].first.present? and reusables["facets"].first['fields'].present?
          reusable_data =  reusables["facets"].first['fields'].map{|a| {a["label"] => a["count"].to_i}}
          aggregation_output.update_attributes(key: "total_results", value: reusables["totalResults"])
          Impl::StaticAttribute.create_or_update_static_data(reusable_data, aggregation_output.id)
          aggregation_output.update_attributes(status: "Processed Reusables")
          aggregation.update_attributes(status: "Processed Reusables")  
        else
          raise "No reusable detected"
        end
        if aggregation.europeana?
          Aggregations::Europeana::PageviewsBuilder.perform_at(1.week.from_now, aggregation_id)
          Impl::DataProviders::MediaTypesBuilder.perform_at(1.week.from_now, aggregation_id)
        else
          Impl::DataProviders::CollectionsBuilder.perform_async(aggregation_id)
        end
      rescue => e
        aggregation_output.update_attributes(status: "Failed to build reusables", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to build reusables", error_messages: e.to_s)
      end
    end
  end
end