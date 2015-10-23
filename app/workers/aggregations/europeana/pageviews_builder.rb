class Aggregations::Europeana::PageviewsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id,user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d"))
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.europeana?
      aggregation.update_attributes(status: "Fetching pageviews", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","pageviews")
      aggregation_output.update_attributes(status: "Fetching pageviews", error_messages: nil)
      begin
        ga_start_date   = user_start_date
        ga_end_date     = user_end_date
        ga_dimensions   = "ga:month,ga:year"
        ga_metrics      = "ga:pageviews"
        ga_filters      = "ga:hostname=~europeana.eu"
        ga_access_token = Impl::DataSet.get_access_token
        page_views = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}").read)["rows"]
        page_views_data = page_views.map{|a| {"month" => a[0], "year" => a[1], "pageviews" => a[2].to_i}}
        page_views_data = page_views_data.sort_by {|d| [d["year"], d["month"]]}
        Core::TimeAggregation.create_time_aggregations("Impl::Output",aggregation_output.id,page_views_data,"pageviews","monthly")
        aggregation.update_attributes(status: "Fetched pageviews", error_messages: nil)
        aggregation_output.update_attributes(status: "Fetched Pageviews", error_messages: nil)
        next_start_date = (Date.today.at_beginning_of_week).strftime("%Y-%m-%d")
        next_end_date = (Date.today.at_end_of_week).strftime("%Y-%m-%d")
        #Creating datacast
        aggregation_datacast_name = "#{aggregation.name} - Pageviews per year"
        aggregation_datacast_query = Impl::Aggregation.get_europeana_query("pageviews")
        aggregation_datacast = Core::Datacast.create_or_update_by(aggregation_datacast_query,aggregation.core_project_id, Core::DbConnection.default_db.id,aggregation_datacast_name)
        aggregation_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,aggregation_datacast.identifier)
        #Creating Vizs
        filter_present, filter_column_name, filter_column_d_or_m = false, nil, nil
        ref_chart = Ref::Chart.find_by_slug("column")
        validate = false
        core_viz = Core::Viz.find_or_create(aggregation_datacast.identifier,aggregation_datacast.name,ref_chart.combination_code,aggregation_datacast.core_project_id,filter_present,filter_column_name,filter_column_d_or_m, validate)

        # #Provider Rank Datacast
        # aggregation_datacast_name = "#{aggregation.name} - Provider Ranks"
        # aggregation_datacast_query = aggregation.get_top_providers_query(5)
        # aggregation_datacast = Core::Datacast.create_or_update_by(aggregation_datacast_query,aggregation.core_project_id, Core::DbConnection.default_db.id,aggregation_datacast_name)
        # aggregation_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,aggregation_datacast.identifier)

        #Fetching Visits
        ga_dimensions   = "ga:month,ga:year,ga:medium"
        ga_metrics      = "ga:visits"
        ga_filters      = "ga:hostname=~europeana.eu"
        ga_access_token = Impl::DataSet.get_access_token
        mediums = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}").read)["rows"]
        mediums_data = mediums.map {|a| {"month" => a[0], "year" => a[1], "medium" => a[2], "visits" => a[3]}}
        mediums_data = mediums_data.sort_by {|d| [d["year"], d["month"]]}
        Core::TimeAggregation.create_aggregations(mediums_data,"monthly",aggregation_id,"Impl::Aggregation","visits","medium")

        #Fetching Countries
        country_output = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "country","pageviews")
        Core::TimeAggregation.create_aggregations(country_output,"monthly", aggregation_id,"Impl::Aggregation","pageviews","country") unless country_output.nil?

        #Fetching Languages
        language_output = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "language","pageviews")
        Core::TimeAggregation.create_aggregations(language_output,"monthly", aggregation_id,"Impl::Aggregation","pageviews","language") unless language_output.nil?

        #Fetching Device Categories
        category_output = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "deviceCategory","pageviews")
        Core::TimeAggregation.create_aggregations(category_output,"monthly", aggregation_id,"Impl::Aggregation","pageviews","deviceCategory") unless category_output.nil?

        #Fetching Device Brands
        branding_output = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "mobileDeviceBranding","pageviews")
        Core::TimeAggregation.create_aggregations(branding_output,"monthly", aggregation_id,"Impl::Aggregation","pageviews","mobileDeviceBranding") unless branding_output.nil?

        #Fetching User Types for Pageviews
        user_type_output_for_pageviews = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "userType","pageviews")
        Core::TimeAggregation.create_aggregations(user_type_output_for_pageviews,"monthly", aggregation_id,"Impl::Aggregation","pageviews","userType") unless user_type_output_for_pageviews.nil?

        #Fetching User Types for Sessions
        user_type_output_for_sessions = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "userType","sessions")
        Core::TimeAggregation.create_aggregations(user_type_output_for_sessions,"monthly", aggregation_id,"Impl::Aggregation","sessions","userType") unless user_type_output_for_sessions.nil?

        #Fetching User Types for avgSessionDuration
        user_type_output_for_avg_session_duration = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "userType","avgSessionDuration")
        Core::TimeAggregation.create_aggregations(user_type_output_for_avg_session_duration,"monthly", aggregation_id,"Impl::Aggregation","avgSessionDuration","userType") unless user_type_output_for_avg_session_duration.nil?

        #Fetching User Types for bounceRate
        user_type_output_for_bounce_rate = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "userType","bounceRate")
        Core::TimeAggregation.create_aggregations(user_type_output_for_bounce_rate,"monthly", aggregation_id,"Impl::Aggregation","bounceRate","userType") unless user_type_output_for_bounce_rate.nil?


        #Fetching User Types for pageviewsPerSession
        user_type_output_for_pageviews_per_session = Impl::Aggregation.fetch_GA_data_between(ga_start_date, ga_end_date, nil, "userType","pageviewsPerSession")
        Core::TimeAggregation.create_aggregations(user_type_output_for_pageviews_per_session,"monthly", aggregation_id,"Impl::Aggregation","pageviewsPerSession","userType") unless user_type_output_for_pageviews_per_session.nil?

        #Creating datacast
        media_for_visits_name = "#{aggregation.name} - Media for Visits"
        media_for_visits_query = aggregation.get_media_for_visits_query
        media_for_visits_datacast = Core::Datacast.create_or_update_by(media_for_visits_query,aggregation.core_project_id, Core::DbConnection.default_db.id,media_for_visits_name)
        aggregation_media_for_visits = Impl::AggregationDatacast.find_or_create(aggregation.id,media_for_visits_datacast.identifier)
        #Creating Vizs
        filter_present, filter_column_name, filter_column_d_or_m = true, "year", "m"
        ref_chart = Ref::Chart.find_by_slug("pie")
        validate = false
        core_viz = Core::Viz.find_or_create(media_for_visits_datacast.identifier,media_for_visits_datacast.name,ref_chart.combination_code,media_for_visits_datacast.core_project_id,filter_present,filter_column_name,filter_column_d_or_m, validate)

      rescue => e
        aggregation_output.update_attributes(status: "Failed to fetch pageviews", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed Fetching pageviews", error_messages: e.to_s)
      end
    end
  end
end