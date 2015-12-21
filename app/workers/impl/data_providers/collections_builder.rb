class Impl::DataProviders::CollectionsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if ["provider","data_provider","country","europeana"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Collections", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","collections")
      aggregation_output.update_attributes(status: "Building Collections", error_messages: nil)
      begin
        europeana_query = aggregation.europeana? ? "*:*" : CGI.escape("#{aggregation.genre.upcase}:\"#{(aggregation.name)}\"")
        collections =  JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{europeana_query}&rows=0").body)
        if collections["totalResults"].present?
          aggregation_output.update_attributes(status: "Processed Collections", key: "total_results", value: collections["totalResults"], content: "", title: "Total Collections")
          aggregation.update_attributes(status: "Processed Collections")
        else
          raise "No Collections detected"
        end
        Impl::DataProviders::MediaTypesBuilder.perform_at(1.week.from_now, aggregation_id)
      rescue => e
        aggregation_output.update_attributes(status: "Failed to build collections", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to build collections", error_messages: e.to_s)
      end
    end
  end
end