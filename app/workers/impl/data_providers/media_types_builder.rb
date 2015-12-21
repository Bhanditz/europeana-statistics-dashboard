class Impl::DataProviders::MediaTypesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if ["country","provider","data_provider","europeana"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Media Types", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","media_type")
      aggregation_output.update_attributes(status: "Building Media Types", error_messages: nil)
      begin
        europeana_query = aggregation.europeana? ? "*:*" : CGI.escape("#{aggregation.genre.upcase}:\"#{(aggregation.name)}\"")
        media_types =  Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{europeana_query}&facet=TYPE&profile=facets&rows=0")
        if media_types["facets"].present? and media_types["facets"].first.present? and media_types["facets"].first["fields"].present?
          media_type_data =  media_types["facets"].first["fields"].map{|a| {a["label"] => a["count"]}}
          Impl::StaticAttribute.create_or_update_static_data(media_type_data, aggregation_output.id)
          aggregation_output.update_attributes(status: "Processed Media Types")
          aggregation.update_attributes(status: "Processed Media Types")
        else
          raise "No media type detected"
        end
        Impl::DataProviders::ReusableBuilder.perform_async(aggregation_id)
      rescue => e
        aggregation_output.update_attributes(status: "Failed to build media types", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to build media types", error_messages: e.to_s)
      end
    end
  end
end