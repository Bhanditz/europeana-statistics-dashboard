class Aggregations::Europeana::PropertiesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Fetches properties of entities from Europeana API's and stores them in the database.
  def perform
    aggregation = Impl::Aggregation.europeana
    if aggregation.genre == "europeana"
      aggregation.update_attributes(status: "Building Properties", error_messages: nil)
      begin
        ["COUNTRY","PROVIDER","DATA_PROVIDER"].each do |property|
          p_down = property.downcase
          properties = JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=#{ENV['WSKEY']}&query=*:*&rows=0&profile=facets,params&facet=#{property}").body)
          if properties["facets"].present? and properties["facets"].first.present? and properties["facets"].first['fields'].present?
            a = properties["facets"].first['fields']
            properties_data = [{"month" => Date.today.month, "year" => Date.today.year, "#{p_down}_count" => p_down, "value" => a.count}]
            Core::TimeAggregation.create_aggregations(properties_data,"monthly", aggregation.id,"Impl::Aggregation","value","#{p_down}_count")
            aggregation.update_attributes(status: "Processed Reusables")
          else
            raise "No #{property.downcase} detected"
          end
        end
        # Run the worker to build datacast for europeana.
        Aggregations::Europeana::DatacastBuilder.perform_async
      rescue => e
        aggregation.update_attributes(status: "Failed to build properties", error_messages: e.to_s)
      end
    end
  end
end