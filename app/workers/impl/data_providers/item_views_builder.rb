class Impl::DataProviders::ItemViewsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Fetches the pageviews for a particular data provider's items and stores it the database.
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
    data_provider.update_attributes(status: "Building item views", error_messages: nil)
    ga_start_date = data_provider.last_updated_at.present? ? (data_provider.last_updated_at+1).strftime("%Y-%m-%d") : "2012-01-01"
    ga_end_date   = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d")
    ga_dimensions = "ga:month,ga:year"
    begin
      #Item Views
      item_views_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","item_views")
      item_views_output.update_attributes(status: "Building item views", error_messages: nil)
      item_views_metrics = "ga:pageviews"
      item_views_filters = "#{data_provider.get_aggregated_filters};ga:pagePath=~/portal/record/"
      item_views_data = Impl::Aggregation.get_ga_data(ga_start_date,ga_end_date,item_views_metrics,ga_dimensions,item_views_filters,"ga:year,ga:month")
      item_views_data = item_views_data.map{|a| {"month" => a[0], "year"=> a[1], "pageviews" => a[2].to_i}}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",item_views_output.id, item_views_data,"pageviews","monthly")
      data_provider.update_attributes(status: "Processed item views")
      item_views_output.update_attributes(status: "Processed item views")
    rescue => e
      data_provider.update_attributes(status: "Failed to build item views",error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
    end
    # Run the worker to collect data of top digital objects for the same instance.
    Impl::DataProviders::TopDigitalObjectsBuilder.perform_async(data_provider_id)

  end
end