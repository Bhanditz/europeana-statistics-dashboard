# frozen_string_literal: true
class Impl::DataProviders::TopCountriesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Fetches and processes pageview data for the data providers for top countries from Google Analytics and formats the data in the required format.
  #
  # @param data_provider_id [Fixnum] id of the instance of Impl:Aggregation where genre is data_provider.
  def perform(data_provider_id)
    data_provider = Impl::Aggregation.find(data_provider_id)
    begin
      raise 'Blacklist data set' if data_provider.blacklist_data_set?
    rescue => e
      data_provider.update_attributes(status: 'Failed', error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
      return nil
    end
    data_provider.update_attributes(status: 'Building top 25 countries', error_messages: nil)
    begin
      start_date = data_provider.last_updated_at.present? ? (data_provider.last_updated_at + 1).strftime('%Y-%m-%d') : '2012-01-01'
      end_date   = (Date.today.at_beginning_of_month - 1).strftime('%Y-%m-%d')
      country_output = Impl::Aggregation.fetch_GA_data_between(start_date, end_date, data_provider, 'country', 'pageviews')
      Core::TimeAggregation.create_aggregations(country_output, 'monthly', data_provider_id, 'Impl::Aggregation', 'pageviews', 'country') unless country_output.nil?
      data_provider.update_attributes(status: 'Processed top 25 countries')
      Impl::DataProviders::ClickThroughBuilder.perform_async(data_provider_id)
    rescue => e
      data_provider.update_attributes(status: 'Failed to build top 25 countries', error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
    end
  end
end
