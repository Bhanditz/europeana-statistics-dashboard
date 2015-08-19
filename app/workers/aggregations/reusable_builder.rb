class Aggregations::ReusableBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'jq'
  require 'jq/extend'

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Building Reusables", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","reusable")
      aggregation_output.update_attributes(status: "Building Reusables", error_messages: nil)
      begin
        reusables = Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{aggregation.genre.upcase}%3a%22#{CGI.escape(aggregation.name)}%22&facet=REUSABILITY&profile=facets&rows=0")
        if reusables["facets"].present?
          reusable_data =  reusables["facets"].jq('.[0].fields | .[] | {(.label):(.count)}')
          Impl::StaticAttribute.create_or_update_static_data(reusable_data, aggregation_output.id)
          aggregation_output.update_attributes(status: "Processed Reusables")
          aggregation.update_attributes(status: "Processed Reusables")  
        else
          raise "No reusable detected"
        end
        Aggregations::CollectionsBuilder.perform_async(aggregation_id)
      rescue => e
        aggregation_output.update_attributes(status: "Failed to build reusables", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed to build reusables", error_messages: e.to_s)
      end
    end
  end
end