class Impl::DataProviders::TrafficBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(data_provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d"))
    data_provider = Impl::Aggregation.data_providers.find(data_provider_id)
    begin
      raise "'Dismarc' data set" if data_provider.dismarc_data_set?
    rescue => e
      data_provider.update_attributes(status: "Failed", error_messages: e.to_s)
      return nil
    end
    data_provider.update_attributes(status: "Building Pageviews", error_messages: nil)
    data_provider_pageviews_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","pageviews")
    data_provider_visits_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","visits")
    data_provider_pageviews_output.update_attributes(status: "Building Pageviews", error_messages: nil)
    ga_start_date   = user_start_date
    ga_end_date     = user_end_date
    ga_dimensions   = "ga:month,ga:year"
    page_view_metrics      = "ga:pageviews"
    visits_metrics    = "ga:visits"
    #Page Views
    begin
      page_view_filters  = data_provider.get_aggregated_filters
      ga_access_token = Impl::DataSet.get_access_token
      page_views = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{page_view_metrics}&dimensions=#{ga_dimensions}&filters=#{page_view_filters}").read)["rows"]
      page_views_data = page_views.map{|a| {"month" => a[0], "year"=> a[1], "pageviews" => a[2].to_i}}
      page_views_data = page_views_data.sort_by {|d| [d["year"], d["month"]]}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",data_provider_pageviews_output.id, page_views_data,"pageviews","monthly")
      data_provider.update_attributes(status: "Building Visits", error_messages: nil)
      data_provider_pageviews_output.update_attributes(status: "Built pageviews", error_messages: nil)
    rescue => e
      data_provider_pageviews_output.update_attributes(status: "Failed to build pageviews", error_messages: e.to_s)
      data_provider.update_attributes(status: "Failed to build pageviews", error_messages: e.to_s)
    end
    #Visits
    begin
      visits_filters   = "#{page_view_filters}"
      data_provider_visits_output.update_attributes(status: "Building visits", error_messages: nil)
      visits = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{visits_metrics}&dimensions=#{ga_dimensions}&filters=#{visits_filters}").read)["rows"]
      visits_data = visits.map{|a| {"month" => a[0], "year"=> a[1], "visits" => a[2].to_i}}
      visits_data = visits_data.sort_by {|d| [d["year"], d["month"]]}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",data_provider_visits_output.id,visits_data,"visits","monthly")
      data_provider.update_attributes(status: "Processed visits", error_messages: nil)
      data_provider_visits_output.update_attributes(status: "Built visits", error_messages: nil)
      Impl::DataProviders::TopCountriesBuilder.perform_async(data_provider_id,user_start_date,user_end_date)
    rescue => e
      data_provider_visits_output.update_attributes(status: "Failed to build visits", error_messages: e.to_s)
      data_provider.update_attributes(status: "Failed to build visits", error_messages: e.to_s)
    end
  end
end