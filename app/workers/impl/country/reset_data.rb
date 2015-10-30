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
      time_lag = 10
      country.child_data_providers.each do |data_provider|
        data_provider.impl_outputs.destroy_all
        Impl::DataProviders::MediaTypesBuilder.perform_at(10.second.from_now,data_provider.id)
        Impl::DataProviders::TrafficBuilder.perform_at(10.second.from_now,data_provider.id)
        Impl::DataProviders::DatacastsBuilder.perform_at(10.second.from_now,data_provider.id)
        time_lag += 10
      end
    rescue => e
      country.update_attributes(status: "Failed to reset data", error_messages: e.to_s)
    end
  
  end
end