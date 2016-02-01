class Impl::DataProviders::TopCountriesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(data_provider_id)
    data_provider = Impl::Aggregation.data_providers.find(data_provider_id)
    begin
      raise "'Dismarc' data set" if data_provider.dismarc_data_set?
    rescue => e
      data_provider.update_attributes(status: "Failed", error_messages: e.to_s)
      return nil
    end
    data_provider.update_attributes(status: "Building top 25 countries", error_messages: nil)
    begin
      start_date = aggregation.last_updated_at.present? ? aggregation.last_updated_at.strftime("%Y-%m-%d") : "2012-01-01"
      end_date   = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d")

      country_output = Impl::Aggregation.fetch_GA_data_between(start_date, end_date, data_provider, "country","pageviews")
      Core::TimeAggregation.create_aggregations(country_output,"quarterly", data_provider_id,"Impl::Aggregation","pageviews","country") unless country_output.nil?
      data_provider.update_attributes(status: "Processed top 25 countries")
      Impl::DataProviders::TopDigitalObjectsBuilder.perform_async(data_provider_id)
    rescue => e
      data_provider.update_attributes(status: "Failed to build top 25 countries",error_messages: e.to_s)
    end
  end

end