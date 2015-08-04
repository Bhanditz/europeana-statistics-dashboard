class Impl::TopCountriesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'active_support/core_ext/date/calculations'
  require 'jq'
  require 'jq/extend'

  def perform(provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d"))
    provider = Impl::Provider.find(provider_id)
    provider.update_attributes(status: "Building top 25 countries", error_messages: nil)
    provider_output = Impl::Output.find_or_create(provider_id,"Impl::Provider","top_10_digital_objects")
    provider_output.update_attributes(status: "Building top 25 countries", error_messages: nil)
    begin
      start_date   = Date.parse(user_start_date)
      end_date     = Date.parse(user_end_date)
      top_25_countries_output = Impl::TopCountriesBuilder.fetch_data_for_all_quarters_between(start_date, end_date, provider)
      top_25_countries_output_to_save = top_25_countries_output.to_json
      provider_output.update_attributes(output: top_25_countries_output_to_save,status: "Processed top 25 countries")
      provider.update_attributes(status: "Processed top 25 countries")
      Impl::Top10DigitalObjectsBuilder.perform_at(60.seconds.from_now, provider_id,user_start_date,user_end_date)
    rescue => e
      provider_output.update_attributes(status: "Failed", error_messages: e.to_s)
      provider.update_attributes(status: "Failed",error_messages: e.to_s)
    end
  end

  def self.fetch_data_for_all_quarters_between(start_date,end_date, provider)
    ga_access_token = Impl::Provider.get_access_token
    puts ga_access_token
    puts "----------------------------"
    ga_dimensions   = "ga:month,ga:year,ga:country"
    ga_metrics      = "ga:pageviews"    
    ga_sort         = '-ga:pageviews'
    ga_filters      = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider.provider_id}"
    ga_max_result   = 25
    ref_isocode = JSON.parse(Ref::CountryCode.all.to_json(only: [:code, :country])).jq('[. [] | { (.country)  : .code }] | add').shift
    top_25_countries_data = []
    while(start_date < end_date)
      ga_start_date = start_date.at_beginning_of_quarter.strftime("%Y-%m-%d")
      ga_end_date   = start_date.at_end_of_quarter > end_date ? end_date : start_date.at_end_of_quarter
      next_quarter_start_date = ga_end_date + 1
      current_quarter = ((ga_end_date.month - 1)/3) + 1
      current_year = ga_end_date.year
      ga_end_date = ga_end_date.strftime("%Y-%m-%d")
      top_25_countries = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_result}").read)['rows']
      if top_25_countries.present?
        top_25_countries.each {|country| top_25_countries_data << {"year" => current_year, "quarter" => current_quarter, "country" => country[2],"size" => country[3], "code" => ref_isocode[country[2]]}} 
      end
      break if ga_end_date == end_date 
      start_date = next_quarter_start_date > end_date ? end_date : next_quarter_start_date
    end
    return top_25_countries_data
  end
end