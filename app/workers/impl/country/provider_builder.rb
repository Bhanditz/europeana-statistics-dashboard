class Impl::Country::ProviderBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(country_id)
    country = Impl::Aggregation.find(country_id)
    if country.genre == 'country'
      country.update_attributes(status: "Building Providers", error_messages: nil)
      begin
        all_providers =  JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=COUNTRY:\"#{country.name.downcase}\"&rows=0&profile=facets,params&facet=PROVIDER").body)['facets'].first
        if all_providers.present? and all_providers['fields'].present?
          all_providers['fields'].each do |provider|
            provider = Impl::Aggregation.create_or_find_aggregation(provider['label'],'provider',country.core_project_id)
            country_provider = Impl::AggregationRelation.create_or_find(country_id,"country", provider.id, "provider")
            query = CGI.escape("COUNTRY:\"#{country.name.downcase}\"  PROVIDER:\"#{provider.name}\"")
            data_providers = JSON.parse(Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{query}&rows=0&profile=facets,params&facet=DATA_PROVIDER").body)
            if data_providers['facets'].present?
              data_providers = data_providers['facets'].first
            else
              next
            end
            if data_providers['fields'].present?
              data_providers["fields"].each do |data_provider|
                data_provider = Impl::Aggregation.create_or_find_aggregation(data_provider['label'],'data_provider',country.core_project_id)
                country_data_provider = Impl::AggregationRelation.create_or_find(country_id,"country", data_provider.id, "data_provider")
                provider_data_provider = Impl::AggregationRelation.create_or_find(provider.id, "provider",data_provider.id, "data_provider")
              end
            end
          end
        end
      rescue => e
        country.update_attributes(status: "Failed to build providers", error_messages: e.to_s)
      end
    end
  end
end