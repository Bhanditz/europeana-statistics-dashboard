class Impl::TrafficBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'active_support/core_ext/date/calculations'
  require 'jq'
  require 'jq/extend'

  def perform(provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d"))
    provider = Impl::Provider.find(provider_id)
    provider.update_attributes(status: "Building Pageviews and Events", error_messages: nil)
    provider_output = Impl::Output.find_or_create(provider_id,"Impl::Provider","traffic")
    provider_output.update_attributes(status: "Building Pageviews and Events", error_messages: nil)
    jq_filter = 'def reduce_keys(f): reduce .[] as $item ({}; .[($item|keys[])] += $item[] ); [[[. [ ] | .rows | . [ ] | .]  | group_by(.[0],.[1]) | .[]| .[0] + .[1] | {month : .[0] , year : .[1], group : "pageview",  value : .[2]}, {month : .[0] , year : .[1], group : "events", value :.[5]}  | .month as $m | .year as $y | .group as $g | .value as $v | $v | tonumber | if($m | tonumber <= 03) then {quarter : "q1", year : $y, value : $v |tonumber, group : $g  } elif($m| tonumber<=06) then {quarter : "q2", year : $y,value : $v|tonumber , group : $g} elif($m| tonumber<=09) then {quarter : "q3", year : $y,value : $v|tonumber , group : $g} else {quarter : "q4", year : $y,value : $v|tonumber , group : $g} end]  | group_by (.quarter, .year, .group) | .[]  as $result | $result | map(with_entries(select(.key == "value"))  ) | reduce_keys(.)  as $r1 | $result | map(with_entries(select(.key != "value"))  ) | .[] as $r2 | $r1*$r2 ] | unique | .[] |{y: .value, x: .quarter,year: .year, group: .group}'
    begin
      #Building the Google Analytics Api Query
      ga_start_date   = user_start_date
      ga_end_date     = user_end_date
      ga_access_token = Impl::Provider.get_access_token
      ga_dimensions   = "ga:month,ga:year"
      #Page Views
      page_view_metrics      = "ga:pageviews"
      page_view_filters      = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider.provider_id}"
      #Events
      events_metrics    = "ga:totalEvents"
      events_filters    = "#{page_view_filters};ga:eventCategory=~Redirect"
      page_views = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{page_view_metrics}&dimensions=#{ga_dimensions}&filters=#{page_view_filters}").read)
      events_data = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{events_metrics}&dimensions=#{ga_dimensions}&filters=#{events_filters}").read)
      traffic_data = [page_views, events_data].jq(jq_filter)
      traffic_data_to_save = traffic_data.to_json
      provider_output.update_attributes(output: traffic_data_to_save,status: "Processed Pageviews and Events")
      provider.update_attributes(status: "Processed Pageviews and Events")
      Impl::TopCountriesBuilder.perform_at(60.seconds.from_now,provider_id,user_start_date,user_end_date)
    rescue => e
      provider_output.update_attributes(status: "Failed", error_messages: e.to_s)
      provider.update_attributes(status: "Failed", error_messages: e.to_s)
    end
  end
end