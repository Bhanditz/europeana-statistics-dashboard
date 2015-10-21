class Aggregations::PageviewTopCountryBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Fetching country with top pageviews", error_messages: nil)
      aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","top_pageviews_country")
      aggregation_output.update_attributes(status: "Fetching country with top pageviews", error_messages: nil)
      begin
        last_day_of_last_month = (Date.today.at_beginning_of_month - 1)
        ga_start_date = last_day_of_last_month.at_beginning_of_month.strftime("%Y-%m-%d")
        ga_end_date = last_day_of_last_month.strftime("%Y-%m-%d")
        metric = "pageviews"
        ga_data = Aggregations::PageviewTopCountryBuilder.fetch_ga_data(ga_start_date,ga_end_date,aggregation.get_aggregated_filters,"ga:pageviews","ga:country", metric).first
        aggregation_output.update_attributes(key: ga_data["country"] , value: ga_data[metric],content: "for last month",title: "Most Pageviews")
      rescue => e
        aggregation_output.update_attributes(status: "Failed to fetch country with top pageviews", error_messages: e.to_s)
        aggregation.update_attributes(status: "Failed Fetching country with top pageviews", error_messages: e.to_s)
      end
      aggregation_output = Impl::Output.find_or_create(aggregation_id, "Impl::Aggregation", "top_users_country")
      last_day_of_last_month = (Date.today.at_beginning_of_month - 1)
      ga_start_date = last_day_of_last_month.at_beginning_of_month.strftime("%Y-%m-%d")
      ga_end_date = last_day_of_last_month.strftime("%Y-%m-%d")
      metric = "users"
      ga_data = Aggregations::PageviewTopCountryBuilder.fetch_ga_data(ga_start_date,ga_end_date,aggregation.get_aggregated_filters,"ga:users","ga:country", metric).first
      aggregation_output.update_attributes(key: ga_data["country"] , value: ga_data[metric],content: "for last month",title: "Most Users")
    end
  end


  def self.fetch_ga_data(ga_start_date, ga_end_date,ga_filters, ga_metrics, ga_dimensions, metric)
    ga_access_token =  Impl::Provider.get_access_token
    ga_sort = "-#{ga_metrics}"
    ga_max_results = "1"
    ga_data = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_results}").read)["rows"].map {|a| {"country" => a[0], "#{metric}" => a[1]}}
    return ga_data
  end
end