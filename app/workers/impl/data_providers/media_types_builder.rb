class Impl::DataProviders::MediaTypesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "Building Media Types", error_messages: nil)
    begin
      europeana_query = aggregation.europeana? ? "*:*" : CGI.escape("#{aggregation.genre.upcase}:\"#{(aggregation.name)}\"")
      media_types =  Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{europeana_query}&facet=TYPE&profile=facets&rows=0")
      if media_types["facets"].present? and media_types["facets"].first.present? and media_types["facets"].first["fields"].present?
        media_type_data =  media_types["facets"].first["fields"].map{|a| {"month" => Date.today.month, "year" => Date.today.year, "media_type" => a["label"], "value" => a["count"].to_i}}
        Core::TimeAggregation.create_aggregations(media_type_data,"monthly", aggregation_id,"Impl::Aggregation","value","media_type")
        aggregation.update_attributes(status: "Processed Media Types")
      else
        raise "No media type detected"
      end
      Impl::DataProviders::ReusableBuilder.perform_async(aggregation_id)
    rescue => e
      aggregation.update_attributes(status: "Failed to build media types", error_messages: e.to_s)
    end
  end
end