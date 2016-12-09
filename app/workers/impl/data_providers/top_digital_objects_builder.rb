# frozen_string_literal: true
class Impl::DataProviders::TopDigitalObjectsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Fetches and processes top digital object data for the non blacklisted data providers and saves then to the database.
  #
  # @param data_provider_id [Fixnum] id of the instance of Impl:Aggregation where genre is data_provider.
  def perform(data_provider_id)
    data_provider = Impl::Aggregation.find(data_provider_id)
    begin
      raise 'Blacklist data set' if data_provider.blacklist_data_set?
    rescue => e
      data_provider.update_attributes(status: 'Failed', error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
      return nil
    end
    data_provider.update_attributes(status: 'Building top digital objects', error_messages: nil)
    begin

      top_digital_objects = Impl::DataProviders::TopDigitalObjectsBuilder.fetch_data_for_all_items_between(data_provider.last_updated_at.present? ? (data_provider.last_updated_at + 1).strftime('%Y-%m-%d') : '2013-01-01', (Date.today.at_beginning_of_month - 1).strftime('%Y-%m-%d'), data_provider)
      Core::TimeAggregation.create_digital_objects_aggregation(top_digital_objects, 'monthly', data_provider_id)
      data_provider.update_attributes(status: 'Processed top 10 digital objects')
      Impl::DataProviders::DatacastsBuilder.perform_async(data_provider_id)
      data_provider.update_attributes(status: 'Built top digital objects', last_updated_at: Date.today.at_beginning_of_month - 1)
    rescue => e
      data_provider.update_attributes(status: 'Failed to build top digital objects', error_messages: e.to_s, last_updated_at: nil)
      data_provider.impl_report.delete if data_provider.impl_report.present?
    end
  end

  # Returns data of pageviews for all top digital objects from Google Analytics, fetching the details of digital objects from Europeana API's
  #
  # @param start_date [String] valid start date to fetch Google Analytics data from.
  # @param end_date [String] a valid date till which Google Analytics data is to be fetched.
  # @param data_provider [Object] an instance of Impl::Aggregation.
  # @return [Array] an array of Hash that is formatted output of Google Analytics and Europeana API's.
  def self.fetch_data_for_all_items_between(start_date, end_date, data_provider)
    top_digital_objects_data = []
    europeana_base_url = ENV['EUROPEANA_API_URL']
    base_title_url = 'http://www.europeana.eu/portal/record/'
    ga_metrics = 'ga:pageviews'
    ga_dimensions = 'ga:pagePath,ga:month,ga:year'
    ga_sort = '-ga:pageviews'
    ga_filters = data_provider.get_aggregated_filters
    ga_max_results = 50
    ga_access_token = Impl::DataSet.get_access_token

    # setup dates
    start_date = Date.parse(start_date)
    end_date = Date.parse(end_date)
    period_end_date = (start_date + 1.month).at_beginning_of_month - 1
    # Go through each month and gather statisitcs
    while period_end_date <= end_date do
      # Format dates as strings for google
      ga_start_date = start_date.strftime('%Y-%m-%d')
      ga_end_date = period_end_date.strftime('%Y-%m-%d')

      top_digital_objects_per_quarter = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_results}", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)['rows']
      if top_digital_objects_per_quarter.present?
        top_digital_objects_per_quarter.each do |digital_object|
          page_path = digital_object[0].split('/')
          if page_path.count == 6 && page_path[3] == 'record'
            page_path.delete_at(2)
          end

          next if page_path[2].downcase != 'record'

          size = digital_object[3].to_i
          begin
            digital_object_europeana_data = JSON.parse(open("#{europeana_base_url}/#{page_path[2]}/#{page_path[3]}/#{page_path[4].split('.')[0]}.json?wskey=#{ENV['WSKEY']}&profile=full").read)
          rescue => e
            #puts "TODO log this error: #{e.inspect}"
            #puts "URL was: #{europeana_base_url}#{page_path[2]}/#{page_path[3]}/#{page_path[4].split('.')[0]}.json?wskey=#{ENV['WSKEY']}&profile=full"
            next
          end
          next if digital_object_europeana_data.nil? || (digital_object_europeana_data['success'] == false)
          image_url = digital_object_europeana_data['object']['europeanaAggregation']['edmPreview'].present? ? digital_object_europeana_data['object']['europeanaAggregation']['edmPreview'] : 'http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO'
          begin
            title = digital_object_europeana_data['object']['proxies'][0]['dcTitle'].first[1].first
          rescue
            title = 'No Title Found'
          end
          title_middle_url = digital_object_europeana_data['object']['europeanaAggregation']['about'].split('/')
          title_url = "#{base_title_url}#{title_middle_url[3]}/#{title_middle_url[4]}.html"
          top_digital_objects_data << { 'image_url' => image_url, 'title' => title, 'title_url' => title_url, 'size' => size, 'year' => digital_object[2], 'month' => digital_object[1] }
        end
      end

      start_date = (start_date + 1.month).at_beginning_of_month
      period_end_date = (start_date + 1.month).at_beginning_of_month - 1
    end
    top_digital_objects_data
  end
end
