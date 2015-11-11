class Impl::DataProviders::ItemViews
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
    data_provider.update_attributes(status: "Building item views", error_messages: nil)
    ga_start_date = user_start_date
    ga_end_date = user_end_date
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
      data_provider.update_attributes(status: "Failed to build item views",error_messages: e.to_s)
    end

    begin
      #Click throughs
      click_through_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","click_throughs")
      click_through_output.update_attributes(status: "Building click throughs", error_messages: nil)
      click_through_metrics = "ga:totalEvents"
      click_through_filters = "#{data_provider.get_aggregated_filters};ga:eventCategory=~Europeana Redirect"
      click_through_data = Impl::Aggregation.get_ga_data(ga_start_date,ga_end_date, click_through_metrics,ga_dimensions,click_through_filters,"ga:year,ga:month")
      click_through_data = click_through_data.map{|a| {"month" => a[0], "year"=> a[1], "totalEvents" => a[2].to_i}}
      Core::TimeAggregation.create_time_aggregations("Impl::Output",click_through_output.id, click_through_data,"totalEvents","monthly")
      click_through_output.update_attributes(status: "Processed click throughs")
      data_provider.update_attributes(status: "Processed click throughs")
    rescue => e
      data_provider.update_attributes(status: "Failed to build click throughs",error_messages: e.to_s)
    end

    begin
      #Media display output
      media_dimensions = "#{ga_dimensions},ga:medium"
      media_display_output = Impl::Output.find_or_create(data_provider_id,"Impl::Aggregation","media_display")
      media_display_output.update_attributes(status: "Building media display", error_messages: nil)
      media_display_metrics = "ga:totalEvents"
      media_display_filters = "#{data_provider.get_aggregated_filters};ga:eventCategory==Europeana Lightbox"
      media_display_data = Impl::Aggregation.get_ga_data(ga_start_date,ga_end_date, media_display_metrics,media_dimensions,media_display_filters,"ga:year,ga:month")
      media_display_data = media_display_data.map{|a| {"month" => a[0], "year"=> a[1],"medium" => a[2],"totalEvents" => a[2].to_i}}
      Core::TimeAggregation.create_aggregations(media_display_data,"monthly",aggregation_id, "Impl::Aggregation","totalEvents","medium")
      media_display_output.update_attributes(status: "Processed media display")
      data_provider.update_attributes(status: "Processed media display")
    rescue => e
      data_provider.update_attributes(status: "Failed to build media display",error_messages: e.to_s)
    end

    begin
      #Search Terms
      search_terms_output = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, data_provider, "searchKeyword","pageviews")
      Core::TimeAggregation.create_aggregations(search_terms_output,"monthly", data_provider_id,"Impl::Aggregation","pageviews","searchKeyword") unless search_terms_output.nil?
      data_provider.update_attributes(status: "Processed search terms")
      Impl::DataProviders::TopDigitalObjectsBuilder.perform_async(data_provider_id, user_start_date,user_end_date)
    rescue => e
      data_provider.update_attributes(status: "Failed to build search terms",error_messages: e.to_s)
    end

  end

end