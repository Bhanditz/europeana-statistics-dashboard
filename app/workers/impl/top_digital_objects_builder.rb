class Impl::TopDigitalObjectsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'active_support/core_ext/date/calculations'

  def perform(provider_id, user_start_date = "2012-01-01",user_end_date = (Date.today.at_beginning_of_week - 1).strftime("%Y-%m-%d"))
    provider = Impl::Provider.find(provider_id)
    provider.update_attributes(status: "Building top digital objects")
    begin
      top_digital_objects = Impl::TopDigitalObjectsBuilder.fetch_data_for_all_quarters_between(user_start_date, user_end_date, provider)
      Core::TimeAggregation.create_digital_objects_aggregation(top_digital_objects,"quarterly", provider_id)
      provider.update_attributes(status: "Processed top 10 digital objects")
      next_start_date = (Date.today.at_beginning_of_week).strftime("%Y-%m-%d")
      next_end_date = (Date.today.at_end_of_week).strftime("%Y-%m-%d")
      Impl::ProivderAggregationDatacastUpdate.perform_async(provider_id)
      Impl::TrafficBuilder.perform_at(1.week.from_now,provider_id,next_start_date, next_end_date)
    rescue => e
      provider.update_attributes(status: "Failed",error_messages: e.to_s)
    end
  end

  def self.fetch_data_for_all_quarters_between(start_date, end_date, provider)
    top_digital_objects_data = []
    europeana_base_url = "http://europeana.eu/api/v2/"
    base_title_url = "http://www.europeana.eu/portal/record/"
    ga_metrics="ga:pageviews"
    ga_dimensions="ga:pagePath,ga:month,ga:year"
    ga_sort= "-ga:pageviews"
    ga_access_token = Impl::Provider.get_access_token
    ga_filters      = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider.provider_id}"
    ga_start_date = start_date
    ga_end_date = end_date
    top_digital_objects_per_quarter = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}").read)["rows"]
    if top_digital_objects_per_quarter.present?
      top_digital_objects_per_quarter.each do |digital_object|
        page_path = digital_object[0].split("/")
        size = digital_object[3].to_i
        begin
          digital_object_europeana_data = JSON.parse(open("#{europeana_base_url}#{page_path[2]}/#{page_path[3]}/#{page_path[4].split(".")[0]}.json?wskey=api2demo&profile=full").read)
        rescue => e
          next
        end
        next if digital_object_europeana_data.nil?
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