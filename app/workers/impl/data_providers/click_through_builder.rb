class Impl::DataProviders::ClickThroughBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require "open-uri"

  # Fetches clickthroughs for the data providers from Google Analytics and formats the data in the required format.
  #
  # @param data_provider_id [Fixnum] id of the instance of Impl:Aggregation where genre is data_provider.
  def perform(data_provider_id)
    data_provider = Impl::Aggregation.find(data_provider_id)
    begin
      raise "Blacklist data set" if data_provider.blacklist_data_set?
    rescue => e
      data_provider.update_attributes(status: "Failed", error_messages: e.to_s,last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
      return nil
    end

    data_provider.update_attributes(status: "Building click through", error_messages: nil)

    data_provider_click_through_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","clickThrough")

    data_provider_click_through_output.update_attributes(status: "Building click through", error_messages: nil)
    ga_start_date = "2012-01-01"
    #To change to last updated at once it runs for all the jobs
    ga_end_date   = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d")

    ga_dimensions   = "ga:year"
    click_metrics  = "ga:totalEvents"
    ga_filter = "ga:eventCategory==Europeana Redirect,ga:eventCategory==Redirect"
    #click Through
    begin

      click_through_filters  = data_provider.get_aggregated_filters
      ga_access_token = Impl::DataSet.get_access_token

      click_through = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{click_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filter};#{click_through_filters}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
      click_through_data = click_through.map{|a| {"year"=> a[0], "clickThrough" => a[1].to_i}}
      click_through_data = click_through_data.sort_by {|d| [d["year"]]}

      Core::TimeAggregation.create_time_aggregations("Impl::Output",data_provider_click_through_output.id, click_through_data,"clickThrough","yearly")
      data_provider_click_through_output.update_attributes(status: "Built click through", error_messages: nil)
      Impl::DataProviders::ItemViewsBuilder.perform_async(data_provider_id)
    rescue => e
      data_provider_click_through_output.update_attributes(status: "Failed to build click through", error_messages: e.to_s)
      data_provider.update_attributes(status: "Failed to build click through", error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
      return nil
    end

  end
end