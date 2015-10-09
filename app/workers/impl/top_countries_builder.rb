class Impl::TopCountriesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'active_support/core_ext/date/calculations'
  require 'jq'
  require 'jq/extend'

  def perform(provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d"))
    provider = Impl::Provider.find(provider_id)
    provider.update_attributes(status: "Building top 25 countries", error_messages: nil)
    begin
      start_date   = user_start_date
      end_date     = user_end_date
      country_output = Impl::TopCountriesBuilder.fetch_data_for_all_quarters_between(start_date, end_date, provider, "country")
      Core::TimeAggregation.create_aggregations(country_output,"quarterly", provider_id,"Impl::Provider","pageviews","country") unless country_output.nil?
      provider.update_attributes(status: "Processed top 25 countries")
      Impl::TopDigitalObjectsBuilder.perform_async(provider_id, user_start_date,user_end_date)
    rescue => e
      provider.update_attributes(status: "Failed to build top 25 countries",error_messages: e.to_s)
    end
  end

  def self.fetch_data_for_all_quarters_between(start_date,end_date, provider=nil, extra_dimension)
    ga_access_token = Impl::Provider.get_access_token
    ga_dimensions   = "ga:month,ga:year,ga:#{extra_dimension}"
    ga_metrics      = "ga:pageviews"
    ga_sort         = '-ga:pageviews'
    data = []
    ga_start_date = start_date
    ga_end_date = end_date
    unless provider.nil?
      ga_filters      = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider.provider_id}"
      query_url = "https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}"
    else
      query_url = "https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&sort=#{ga_sort}"
    end
    top_25_countries = JSON.parse(open(query_url).read)['rows']
    if top_25_countries.present?
      data = top_25_countries.jq(". [ ] | {month: .[0], year: .[1], #{extra_dimension}: .[2], pageviews: .[3]|tonumber}")
      data = data.sort_by {|d| [d["year"], d["month"]]}
    end
    return data
  end
end