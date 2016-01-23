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
        page_views = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
        page_views_data = page_views.map{|a| {"month" => a[0], "year" => a[1], "pageviews" => a[2].to_i}}
        page_views_data = page_views_data.sort_by {|d| [d["year"], d["month"]]}
        Core::TimeAggregation.create_time_aggregations("Impl::Output",aggregation_output.id,page_views_data,"pageviews","monthly")
        aggregation.update_attributes(status: "Fetched pageviews", error_messages: nil)
        aggregation_output.update_attributes(status: "Fetched Pageviews", error_messages: nil)
        next_start_date = (Date.today.at_beginning_of_week).strftime("%Y-%m-%d")
        next_end_date = (Date.today.at_end_of_week).strftime("%Y-%m-%d")
        #Fetching Visits
        ga_dimensions   = "ga:month,ga:year,ga:medium"
        ga_metrics      = "ga:visits"
        ga_filters      = "ga:hostname=~europeana.eu"
        ga_access_token = Impl::DataSet.get_access_token
        mediums = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
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
        Aggregations::Europeana::DatacastBuilder.perform_async(aggregation_id)

        #Top Digital Objects
        top_digital_objects = Aggregations::Europeana::PageviewsBuilder.fetch_data_for_all_quarters_between(user_start_date, user_end_date)
        Core::TimeAggregation.create_digital_objects_aggregation(top_digital_objects,"monthly", aggregation.id)

      rescue => e
        aggregation_output.update_attributes(status: "Failed to fetch pageviews", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed Fetching pageviews", error_messages: e.to_s)
      end
    end
  end


  def self.fetch_data_for_all_quarters_between(start_date, end_date)
    top_digital_objects_data = []
    ga_access_token = Impl::DataSet.get_access_token
    europeana_base_url = "http://europeana.eu/api/v2/"
    base_title_url = "http://www.europeana.eu/portal/record/"
    ga_metrics="ga:pageviews"
    ga_dimensions="ga:pagePath,ga:month,ga:year"
    ga_sort= "-ga:pageviews"
    ga_filters  = "ga:hostname=~europeana.eu;ga:pagePath=~/portal/record/"
    ga_start_date = start_date
    ga_end_date = end_date
    top_digital_objects_per_quarter = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
    if top_digital_objects_per_quarter.present?
      top_digital_objects_per_quarter.each do |digital_object|
        page_path = digital_object[0].split("/")
        size = digital_object[3].to_i
        begin
          digital_object_europeana_data = JSON.parse(open("#{europeana_base_url}#{page_path[2]}/#{page_path[3]}/#{page_path[4].split(".")[0]}.json?wskey=api2demo&profile=full").read)
        rescue => e
          next
        end
        next if ((digital_object_europeana_data.nil?) or (digital_object_europeana_data["success"] == false))
        image_url = digital_object_europeana_data["object"]['europeanaAggregation']['edmPreview'].present? ? digital_object_europeana_data["object"]['europeanaAggregation']['edmPreview'] : "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO"
        begin
          title = digital_object_europeana_data["object"]["proxies"][0]['dcTitle'].first[1].first
        rescue => e
          title = "No Title Found"
        end
        title_middle_url = digital_object_europeana_data["object"]['europeanaAggregation']['about'].split("/")
        title_url = "#{base_title_url}#{title_middle_url[3]}/#{title_middle_url[4]}.html"
        top_digital_objects_data << {"image_url" => image_url, "title" => title, "title_url" => title_url, "size" => size, "year" => digital_object[2], "month" =>digital_object[1] }
      end
    end
    return top_digital_objects_data
  end

end