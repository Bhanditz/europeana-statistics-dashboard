class Impl::TrafficBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'jq'
  require 'jq/extend'

  def perform(provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d"))
    provider = Impl::Provider.find(provider_id)
    provider.update_attributes(status: "Building Pageviews", error_messages: nil)
    provider_pageviews_output = Impl::Output.find_or_create(provider_id,"Impl::Provider","pageviews_for_traffic")
    provider_events_output = Impl::Output.find_or_create(provider_id,"Impl::Provider","events_for_traffic")
    provider_pageviews_line_chart_output = Impl::Output.find_or_create(provider_id,"Impl::Provider","pageviews")
    provider_pageviews_output.update_attributes(status: "Building Pageviews", error_messages: nil)
    ga_start_date   = user_start_date
    ga_end_date     = user_end_date
    ga_dimensions   = "ga:month,ga:year"
    page_view_metrics      = "ga:pageviews"
    page_view_filters      = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider.provider_id}"
    page_view_jq_filter    = '. | .[] | {month: .[0],year: .[1], pageviews: .[2]|tonumber}'
    events_metrics    = "ga:totalEvents"
    events_filters    = "#{page_view_filters};ga:eventCategory=~Redirect"
    events_jq_filter  = '. | .[] | {month: .[0],year: .[1], events: .[2]|tonumber}'
    #Page Views
    begin
      ga_access_token = Impl::Provider.get_access_token
      page_views = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{page_view_metrics}&dimensions=#{ga_dimensions}&filters=#{page_view_filters}").read)["rows"]
      page_views_data = page_views.jq(page_view_jq_filter)
      page_views_data = page_views_data.sort_by {|d| [d["year"], d["month"]]}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",provider_pageviews_output.id,page_views_data,"pageviews","quarterly")
      Core::TimeAggregation.create_time_aggregations("Impl::Output",provider_pageviews_line_chart_output.id, page_viewsviews_data,"pageviews","monthly")
      provider.update_attributes(status: "Building Events", error_messages: nil)
      provider_pageviews_line_chart_output.update_attributes(status: "Built pageviews", error_messages: nil)
      provider_pageviews_output.update_attributes(status: "Built pageviews", error_messages: nil)
    rescue => e
      provider_pageviews_line_chart_output.update_attributes(status: "Failed to build pageviews", error_messages: e.to_s)
      provider_pageviews_output.update_attributes(status: "Failed to build pageviews", error_messages: e.to_s)
      provider.update_attributes(status: "Failed to build pageviews", error_messages: e.to_s)
    end
    #Events
    begin
      provider_events_output.update_attributes(status: "Building events", error_messages: nil)
      events = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{events_metrics}&dimensions=#{ga_dimensions}&filters=#{events_filters}").read)["rows"]
      events_data = events.jq(events_jq_filter)
      events_data = events_data.sort_by {|d| [d["year"], d["month"]]}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",provider_events_output.id,events_data,"events","quarterly")
      provider.update_attributes(status: "Processed events", error_messages: nil)
      provider_events_output.update_attributes(status: "Built events", error_messages: nil)
      Impl::TopCountriesBuilder.perform_async(provider_id,user_start_date,user_end_date)
    rescue => e
      provider_events_output.update_attributes(status: "Failed to build events", error_messages: e.to_s)
      provider.update_attributes(status: "Failed to build events", error_messages: e.to_s)
    end
  end
end