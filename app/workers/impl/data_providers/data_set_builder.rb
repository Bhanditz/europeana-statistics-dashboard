class Impl::DataProviders::DataSetBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(data_provider_id)
    data_provider = Impl::Aggregation.find(data_provider_id)
    if data_provider.genre == 'data_provider'
      data_provider.update_attributes(status: "Building Data Sets", error_messages: nil)
      begin
        all_data_sets =  JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{CGI.escape('DATA_PROVIDER:"'+data_provider.name+'"')}&rows=0&profile=facets,params&facet=europeana_collectionName").body)['facets'].first
        if all_data_sets.present? and all_data_sets['fields'].present?
          all_data_sets['fields'].each do |data_set|
            d_set = Impl::DataSet.find_or_create(data_set['label'])
            data_provider_data_set = Impl::DataProviderDataSet.create({impl_aggregation_id: data_provider_id,impl_data_set_id: d_set.id })
          end
        else
          raise "No data set found"
        end
      rescue => e
        aggregation.update_attributes(status: "Failed to build data sets", error_messages: e.to_s)
      end
    end
  end
end