class Aggregations::CollectionsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'jq'
  require 'jq/extend'

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if ["provider","data_provider","europeana"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Collections", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","collections")
      aggregation_output.update_attributes(status: "Building Collections", error_messages: nil)
      begin
        europeana_query = aggregation.europeana? ? "Europeana" : "#{aggregation.genre.upcase}%3a%22#{CGI.escape(aggregation.name)}%22"
        collections =  JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{europeana_query}&rows=0").body)
        if collections["totalResults"].present?
          aggregation_output.update_attributes(status: "Processed Collections", key: "total_results", value: collections["totalResults"], content: "digital objects in europeana", title: "Total Collections")
          aggregation.update_attributes(status: "Processed Collections")
        else
          raise "No Collections detected"
        end
        if aggregation.europeana?
          Aggregations::EuropeanaPageviewsBuilder.perform_async(aggregation_id)
          Aggregations::CollectionsBuilder.perform_at(1.week.from_now, aggregation_id)
        else
          Aggregations::MediaTypesBuilder.perform_at(1.week.from_now, aggregation_id)
        end
      rescue => e
        aggregation_output.update_attributes(status: "Failed to build collections", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to build collections", error_messages: e.to_s)
      end
    end
  end
end