class Impl::Country::ResetData
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(country_id)
    country = Impl::Aggregation.countries.find(country_id)
    country.update_attributes(status: "Resetting data for country", error_messages: nil)
    begin
      country.impl_outputs.destroy_all
      country.child_providers.each do |provider|
        provider.impl_outputs.destroy_all
      end
      country.child_data_providers.each do |data_provider|
        data_provider.update_column(last_updated_at: nil)
        data_provider.impl_outputs.destroy_all
        Impl::DataProviders::MediaTypesBuilder.perform_async(data_provider.id)
        Impl::DataProviders::TrafficBuilder.perform_async(data_provider.id)
        Impl::DataProviders::DatacastsBuilder.perform_async(data_provider.id)
      end
    rescue => e
      country.update_attributes(status: "Failed to reset data", error_messages: e.to_s)
    end
  
  end
end