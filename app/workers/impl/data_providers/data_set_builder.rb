class Impl::DataProviders::DataSetBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    unless aggregation.genre == 'europeana'
      aggregation.update_attributes(status: "Building Data Sets", error_messages: nil)
      begin
        all_data_sets =  JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=SQkKyghXb&query=#{CGI.escape(aggregation.genre.upcase+':"'+aggregation.name+'"')}&rows=0&profile=facets,params&facet=europeana_collectionName").body)['facets'].first
        if all_data_sets.present? and all_data_sets['fields'].present?
          all_data_sets['fields'].each do |data_set|
            d_set = Impl::DataSet.find_or_create(data_set['label'])
            aggregation_data_set = Impl::AggregationDataSet.create({impl_aggregation_id: aggregation_id,impl_data_set_id: d_set.id })
          end
          Impl::DataProviders::TrafficBuilder.perform_async(aggregation_id)
        else
          raise "No data set found"
        end
      rescue => e
        aggregation.update_attributes(status: "Failed to build data sets", error_messages: e.to_s)
      end
    end
  end
end