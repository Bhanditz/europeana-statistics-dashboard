# == Schema Information
#
# Table name: impl_aggregations
#
#  id              :integer          not null, primary key
#  core_project_id :integer
#  genre           :string
#  name            :string
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :string
#  error_messages  :string
#  properties      :hstore
#  last_updated_at :date
#

class Impl::Aggregation < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregations"
  include ActionView::Helpers::NumberHelper

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties
  #ASSOCIATIONS
  has_many :impl_child_data_providers,->{(data_providers)},class_name: "Impl::AggregationRelation", foreign_key: "impl_parent_id", dependent: :destroy
  has_many :impl_child_providers,->{(providers)} ,class_name: "Impl::AggregationRelation", foreign_key: "impl_parent_id", dependent: :destroy
  has_many :child_data_providers, through: :impl_child_data_providers, source: :impl_child
  has_many :child_providers, through: :impl_child_providers, source: :impl_child
  has_many :impl_parent_countries, -> {(parent_countries)},class_name: "Impl::AggregationRelation", foreign_key: "impl_child_id", dependent: :destroy
  has_many :impl_parent_providers, -> {(parent_providers)},class_name: "Impl::AggregationRelation", foreign_key: "impl_child_id", dependent: :destroy
  has_many :parent_countries, through: :impl_parent_countries, source: :impl_parent
  has_many :parent_providers, through: :impl_parent_providers, source: :impl_parent
  has_many :impl_aggregation_data_sets,class_name: "Impl::AggregationDataSet", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :impl_data_sets, through: :impl_aggregation_data_sets
  has_many :impl_aggregation_datacasts, class_name: "Impl::AggregationDatacast", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :core_datacasts, through: :impl_aggregation_datacasts, dependent: :destroy
  has_many :core_vizs, through: :core_datacasts, dependent: :destroy
  has_many :impl_outputs, class_name: "Impl::Output", foreign_key: "impl_parent_id", dependent: :destroy
  has_one :impl_report, class_name: "Impl::Report", foreign_key: "impl_aggregation_id", dependent: :destroy

  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :genre, presence: true, inclusion: {in: ["provider","data_provider","country","europeana"]}
  validates :name, presence: true, uniqueness: {scope: :genre}

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  scope :data_providers, -> {where(genre: "data_provider")}
  scope :providers, -> {where(genre: "provider")}
  scope :countries, ->{where(genre: "country")}
  scope :europeana, -> {where(genre: "europeana").first}

  #CUSTOM SCOPES
  #FUNCTIONS

  # Returns a static SQL query for the genre specified.
  #
  # @param genre [String]
  # @return [String] a SQL Query.
  def get_static_query(genre)
    today = Date.today
    return "Select name, value as weight from core_time_aggregations INNER JOIN (Select id as impl_output_id, value as name from impl_outputs where impl_parent_id = #{self.id} and genre = 'top_#{genre.pluralize}') as io on parent_id = impl_output_id and parent_type = 'Impl::Output' where aggregation_level_value = '#{today.year}_#{Date::MONTHNAMES[today.month]}'"
  end

  # Returns a static SQL query for digital objects.
  def get_digital_objects_query
    year = Date.today.year
    return "Select year,month, value,image_url,title_url,title  from (Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta.aggregation_level_value, '_',2) as month, sum(ta.value) as value,ta.aggregation_index, output_properties -> 'image_url' as image_url, output_properties -> 'title_url' as title_url, output_value as title, ROW_NUMBER() OVER (PARTITION BY  split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2) order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), sum(value) desc) AS row  from core_time_aggregations ta, (Select o.id as output_id, o.key as output_key, o.value as output_value, o.properties as output_properties from impl_outputs o where o.impl_parent_id = #{self.id} and genre='top_digital_objects') as b where ta.parent_id = b.output_id group by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), ta.aggregation_value_to_display, ta.metric,ta.aggregation_index, output_properties -> 'image_url', output_properties -> 'title_url', output_value order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), value desc) as final_output where row < 25 and year::integer in (#{(2014..year).to_a.join(",")});"
  end

  # Returns a static SQL query for countries.
  def get_countries_query
    year = Date.today.year
    return "Select sum(ta.value) as size, b.code as iso2, 'Pageviews' as tooltip_column_name from core_time_aggregations as ta, (Select o.id as output_id, value, code from impl_outputs o,ref_country_codes as code where o.impl_parent_id = #{self.id} and o.genre='top_countries' and o.value = code.country) as b where ta.parent_id = b.output_id and split_part(ta.aggregation_level_value,'_',1)='#{year}' group by b.code order by size desc limit 10"
  end

  # Returns a static SQL query for fetching data for the line chart.
  def get_pageviews_line_chart_query
    year = Date.today.year
    month = Date::MONTHNAMES[Date.today.month]
    return "Select name, x,y from (Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o where impl_parent_id = #{self.id}  and genre='pageviews') as b  on parent_type='Impl::Output' and parent_id = output_id group by ta.aggregation_level_value,aggregation_value_to_display order by split_part(ta.aggregation_level_value,'_',1),to_date(aggregation_value_to_display,'Month')) as final_output where (year::integer < #{year} or x <> '#{month}') and year::integer > 2012;"
  end

  # Runs a background job that invokes job to fetch all data from Google Analytics.
  def restart_all_jobs
    Impl::DataProviders::RestartWorker.perform_async(self.id)
  end

  # Returns the Google analytics filter string.
  def get_aggregated_filters
    filter = "ga:hostname=~europeana.eu;"
    impl_data_sets = self.impl_data_sets
    raise "No data set" if impl_data_sets.count == 0
    raise "No data set" if (impl_data_sets.count == 1 and Constants::FILTERED_280_DATASETS.include?(impl_data_sets.first.name))

    impl_data_sets.each do |p|
      filter += "ga:pagePath=~/#{p.data_set_id.strip}/," unless Constants::FILTERED_280_DATASETS.include?(p.name) and self.genre == 'data_provider'
    end
    return filter[0..-2]
  end

  # Returns the rows where the genre is europeana
  def europeana?
    return self.genre == "europeana"
  end

  # Returns data providers that have been blacklisted.
  def blacklist_data_set?
    return (self.genre == "data_provider" and (self.impl_data_sets.pluck(:name).uniq & Impl::BlacklistDataset.get_blacklist_datasets).present?)
  end

  # Either creates a new Impl::Aggregation or returns an existing Impl::Aggregation object from the database.
  #
  # @param name [String] the name of the aggregation.
  # @param genre [String] entity to which the current aggregation belongs to.
  # @param core_project_id [Fixnum] id of the reference to Core::Project.
  # @return [Object] an instance of Impl::Aggregation.
  def self.create_or_find_aggregation(name, genre, core_project_id)
    aggregation = where(name:name, genre: genre, core_project_id: core_project_id).first
    if aggregation.nil?
      aggregation = create({name: name, genre: genre, core_project_id: core_project_id, status: ""})
    end
    aggregation
  end

  # Fetches data from Google Analytics.
  #
  # @param start_date [String] valid start date to fetch Google Analytics data from.
  # @param end_date [String] a valid date till which Google Analytics data is to be fetched.
  # @param data_provider [object] an instance of Impl::Aggregation where genre is data_provider.
  # @param extra_dimension [String] an extra Google Analytics dimension for query.
  # @param metric [String] string of Google Analytics metric for which data is to be fetched.
  # @return [Array] the data from Google Analytics.
  def self.fetch_GA_data_between(start_date, end_date, data_provider=nil, extra_dimension, metric)
    ga_access_token = Impl::DataSet.get_access_token
    ga_dimensions   = "ga:month,ga:year,ga:#{extra_dimension}"
    ga_metrics      = "ga:#{metric}"
    ga_sort         = "-ga:#{metric}"
    ga_start_date = start_date
    ga_end_date = end_date
    unless data_provider.nil?
      ga_filters = data_provider.get_aggregated_filters
      query_url = "https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&filters=#{ga_filters}&sort=#{ga_sort}"
    else
      query_url = "https://www.googleapis.com/analytics/v3/data/ga?access_token=#{ga_access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{GA_IDS}&metrics=#{ga_metrics}&dimensions=#{ga_dimensions}&sort=#{ga_sort}"
    end
    data = JSON.parse(open(query_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)
    if data["totalResults"].to_i > 0
      data = data['rows']
      if data.present?
        data = data.map{|a| {"month" => a[0], "year"=> a[1], "#{extra_dimension}" => a[2], "#{metric}" => a[3].to_i}}
        data = data.sort_by {|d| [d["year"], d["month"]]}
      end
    else
      data = []
    end
    return data
  end

  # Fetches data from Google Analytics based on filters, metric, dimension and sort order.
  #
  # @param start_date [String] valid start date to fetch Google Analytics data from.
  # @param end_date [String] a valid date till which Google Analytics data is to be fetched.
  # @param metrics [String] string of Google Analytics metric for which data is to be fetched.
  # @param dimensions [String] string of Google Analytics dimensions for which data is to be fetched.
  # @param filters [String] string of Google Analytics filters to be applied while fetching the data.
  # @param sort [String] string to specify the columns to be used to sort the GA data.
  # @return [Array] the data from Google Analytics.
  def self.get_ga_data(start_date, end_date, metrics, dimensions, filters, sort)
    ga_access_token = Impl::DataSet.get_access_token
    data = []
    begin
      data = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{start_date}&end-date=#{end_date}&ids=ga:#{GA_IDS}&metrics=#{metrics}&dimensions=#{dimensions}&filters=#{filters}&sort=#{sort}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
    rescue
      nil
    end
    return data
  end

  # Retruns and caches the JSON for data providers that is used in views to display data.
  def self.get_data_providers_json
    json = []
    if $redis.get("data_providers_json").present?
      json = JSON.parse($redis.get("data_providers_json"))
    else
      self.data_providers.order(:name).find_by_sql("Select * from impl_aggregations where EXISTS (Select impl_aggregation_id from impl_reports where impl_reports.impl_aggregation_id = impl_aggregations.id) and impl_aggregations.genre='data_provider' ORDER BY impl_aggregations.name;").each do |data_provider|
          obj = {
            "url" => "#{BASE_URL}/dataprovider/#{data_provider.impl_report.slug}",
            "text" => "#{data_provider.name}"
          }
          json << obj
      end
      $redis.set("data_providers_json", json.to_json)
      $redis.expire("data_providers_json", 60*60*24)
    end
    json
  end

  # Retruns and caches the JSON for providers that is used in views to display data.
  def self.get_providers_json
    json = []
    if $redis.get("providers_json").present?
      json = JSON.parse($redis.get("providers_json"))
    else
      self.providers.order(:name).find_by_sql("Select * from impl_aggregations where EXISTS (Select impl_aggregation_id from impl_reports where impl_reports.impl_aggregation_id = impl_aggregations.id) and impl_aggregations.genre='provider' ORDER BY impl_aggregations.name;").each do |provider|
        obj = {
          "url" => "#{BASE_URL}/provider/#{provider.impl_report.slug}",
          "text" => "#{provider.name}"
        }
        json << obj
      end
      $redis.set("providers_json", json.to_json)
      $redis.expire("providers_json", 60*60*24)
    end
    json
  end

  # Retruns and caches the JSON for countries that is used in views to display data.
  def self.get_countries_json
    json = []
    if $redis.get("countries_json").present?
      json = JSON.parse($redis.get("countries_json"))
    else
      self.find_by_sql("Select * from impl_aggregations where EXISTS (Select impl_aggregation_id from impl_reports where impl_reports.impl_aggregation_id = impl_aggregations.id) and impl_aggregations.genre='country' ORDER BY impl_aggregations.name;").each do |country|
        obj = {
          "url" => "#{BASE_URL}/country/#{country.impl_report.slug}",
          "text" => "#{country.name.titleize}"
        }
        json << obj
      end
      $redis.set("countries_json", json.to_json)
      $redis.expire("countries_json", 60*60*24)
    end
    json
  end

  # Retruns SQL query for getting the count of data providers.
  def get_data_providers_count_query
    return "Select count(*) as value, '' as key, '' as content, 'Total Institutions' as title, '' as diff_in_value from impl_aggregation_relations where impl_parent_genre='#{self.genre}' and impl_child_genre='data_provider' and impl_parent_id = '#{self.id}'"
  end

  # Retruns SQL query for getting the count of an aggregation if genre is either of the following ["country","provider","data_provider"].
  def get_aggregations_count_query(genre=nil)
    return "" if self.genre != 'europeana' and ["country","provider","data_provider"].include?(genre)
    today = Date.today
    return "Select cta.value, '' as key, '' as content, 'Total #{genre.titleize.pluralize}' as title, '' as diff_in_value,io.genre  from impl_outputs io INNER JOIN  core_time_aggregations cta on parent_id = io.id and parent_type = 'Impl::Output' and io.impl_parent_id = 1 and genre = 'top_#{genre}_counts' and split_part(aggregation_level_value,'_',1) = '#{today.year}' and split_part(aggregation_level_value,'_',2) = '#{Date::MONTHNAMES[today.month]}'"
  end

  #PRIVATE
  private

  def before_create_set
    self.status = "In queue"
    self.name = self.name.strip if self.name.present?
    true
  end

  def after_create_set
    if self.genre == 'country'
      Impl::Country::ProviderBuilder.perform_async(self.id)
    end
    Impl::DataProviders::DataSetBuilder.perform_async(self.id)
    Impl::DataProviders::MediaTypesBuilder.perform_async(self.id)
    true
  end
end
