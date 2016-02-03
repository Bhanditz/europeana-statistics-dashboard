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
  store_accessor :properties, :wikipedia_content, :wikiname
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
  validates :name, presence: true, uniqueness: {scope: ["core_project_id","genre"]}

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

  def get_static_query(genre)
    today = Date.today
    return "Select name, value as weight from core_time_aggregations INNER JOIN (Select id as impl_output_id, value as name from impl_outputs where impl_parent_id = #{self.id} and genre = 'top_#{genre.pluralize}') as io on parent_id = impl_output_id and parent_type = 'Impl::Output' where aggregation_level_value = '#{today.year}_#{Date::MONTHNAMES[today.month]}'"
  end

  def get_digital_objects_query
    year = Date.today.year
    return "Select year,month, value,image_url,title_url,title  from (Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta.aggregation_level_value, '_',2) as month, sum(ta.value) as value,ta.aggregation_index, output_properties -> 'image_url' as image_url, output_properties -> 'title_url' as title_url, output_value as title, ROW_NUMBER() OVER (PARTITION BY  split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2) order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), sum(value) desc) AS row  from core_time_aggregations ta, (Select o.id as output_id, o.key as output_key, o.value as output_value, o.properties as output_properties from impl_outputs o where o.impl_parent_id = #{self.id} and genre='top_digital_objects') as b where ta.parent_id = b.output_id group by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), ta.aggregation_value_to_display, ta.metric,ta.aggregation_index, output_properties -> 'image_url', output_properties -> 'title_url', output_value order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), value desc) as final_output where row < 25 and year::integer in (#{(2014..year).to_a.join(",")});"
  end


  def get_countries_query
    year = Date.today.year
    return "Select sum(ta.value) as size, b.code as iso2 from core_time_aggregations as ta, (Select o.id as output_id, value, code from impl_outputs o,ref_country_codes as code where o.impl_parent_id = #{self.id} and o.genre='top_countries' and o.value = code.country) as b where ta.parent_id = b.output_id and split_part(ta.aggregation_level_value,'_',1)='#{year}' group by b.code order by size desc limit 10"
  end

  def get_collections_query
    return "Select o.value, o.properties -> 'title' as title, o.properties -> 'content' as content, '' as key, '' as diff_in_value from impl_aggregations a, impl_outputs o where a.id = #{self.id} and o.genre='collections' and o.impl_parent_id = #{self.id}"
  end

  def get_pageviews_line_chart_query
    year = Date.today.year
    month = Date::MONTHNAMES[Date.today.month]
    return "Select name, x,y from (Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o where impl_parent_id = #{self.id}  and genre='pageviews') as b  on parent_type='Impl::Output' and parent_id = output_id group by ta.aggregation_level_value,aggregation_value_to_display order by split_part(ta.aggregation_level_value,'_',1),to_date(aggregation_value_to_display,'Month')) as final_output where (year::integer < #{year} or x <> '#{month}');"

  end

  def restart_all_jobs
    Impl::DataProviders::RestartWorker.perform_async(self.id)
  end

  def top_digital_objects_auto_html
    datacast = self.core_datacasts.top_digital_objects.first
    return "<div id='#{datacast.name.parameterize("_")}' data-datacast_identifier='#{datacast.identifier}' class='top_digital_objects'></div>"
  end

  def get_aggregated_filters
    filter = "ga:hostname=~europeana.eu;"
    impl_data_sets = self.impl_data_sets
    raise "No data set" if impl_data_sets.count == 0
    last_id = impl_data_sets.last.id
    impl_data_sets.each do |p|
      filter += "ga:pagePath=~/#{p.data_set_id.strip}/#{p.id == last_id ? "" : ","}"
    end
    return filter
  end

  def europeana?
    return self.genre == "europeana"
  end

  def dismarc_data_set?
    return self.impl_data_sets.pluck(:name).uniq.include?("2023601_Ag_DE_DISMARC")
  end

  def self.create_or_find_aggregation(name, genre, core_project_id)
    aggregation = where(name:name, genre: genre, core_project_id: core_project_id).first
    if aggregation.nil?
      aggregation = create({name: name, genre: genre, wikiname: nil,core_project_id: core_project_id, status: ""})
    end
    aggregation
  end

  def get_media_for_visits_query
    return "Select sum(value) as weight, name, split_part(aggregation_level_value,'_',1) as year from core_time_aggregations cta join (Select io.id as impl_output_id, value as name from impl_outputs io join impl_aggregations ia on io.impl_parent_id=ia.id and io.impl_parent_type ='Impl::Aggregation' and ia.name='Europeana' and io.genre='top_media') as impl_aggregation_output on parent_id = impl_output_id and parent_type='Impl::Output' group by name,split_part(aggregation_level_value,'_',1) order by split_part(aggregation_level_value,'_',1)"
  end


  def self.get_europeana_query(metric)
    return "Select sum(value) as y,split_part(aggregation_level_value,'_',1) as x from core_time_aggregations cta join (select io.id as impl_output_id from impl_outputs io join impl_aggregations ia on io.impl_parent_id = ia.id and io.impl_parent_type='Impl::Aggregation' and ia.genre='europeana' and io.genre='#{metric}') as iao on cta.parent_id = iao.impl_output_id and cta.parent_type='Impl::Output' group by metric, split_part(aggregation_level_value,'_',1) order by split_part(aggregation_level_value,'_',1)"
  end

  def self.fetch_GA_data_between(start_date,end_date, data_provider=nil, extra_dimension, metric)
    ga_access_token = Impl::DataSet.get_access_token
    ga_dimensions   = "ga:month,ga:year,ga:#{extra_dimension}"
    ga_metrics      = "ga:#{metric}"
    ga_sort         = "-ga:#{metric}"
    data = []
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

  def self.get_ga_data(start_date,end_date, metrics,dimensions,filters,sort)
    ga_access_token = Impl::DataSet.get_access_token
    data = []
    begin
      data = JSON.parse(open("#{GA_ENDPOINT}?access_token=#{ga_access_token}&start-date=#{start_date}&end-date=#{end_date}&ids=ga:#{GA_IDS}&metrics=#{metrics}&dimensions=#{dimensions}&filters=#{filters}&sort=#{sort}", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)["rows"]
    rescue => e
    end
    return data
  end

  def self.get_data_providers_html
    data_providers = []
    html_string = "<table class='table'><thead><th>Name</th></thead>"
    self.data_providers.includes(:impl_outputs).each do |data_provider|
      data_providers << {slug: data_provider.name.parameterize("-"),  name: data_provider.name}
    end
    data_providers.each do |d|
      html_string += "<tr><td><a href='#{BASE_URL}/#{d[:slug]}'>#{d[:name]}</a></td></tr>"
    end
    html_string += "</table>"
    html_string
  end

  def self.get_providers_html
    providers = []
    html_string = "<table class='table'><thead><th>Name</th></thead>"
    self.providers.includes(:impl_outputs).each do |provider|
      providers << {slug: provider.name.parameterize("-"),  name: provider.name}
    end
    providers.each do |d|
      html_string += "<tr><td><a href='#{BASE_URL}/#{d[:slug]}'>#{d[:name]}</a></td></tr>"
    end
    html_string += "</table>"
    html_string
  end

  def self.get_countries_html
    html_string = "<table class='table'><thead><th>Country name</th></thead>"
    countries = []
    self.countries.includes(:impl_outputs).each do |country|
      countries << {slug: country.impl_report.present? ? country.impl_report.slug : country.name.parameterize("-"), name: country.name}
    end
    countries.each{|d| html_string += "<tr><td><a href='#{BASE_URL}/#{d[:slug]}'>#{d[:name]}</a></td></tr>"}
    html_string += "</table>"
    return html_string
  end

  def get_total_visits_query
    year = 2015 #Date.today.year
    return "Select sum(value) as value, '' as key, '' as content, 'Total Visits in #{year}' as title, '' as diff_in_value from core_time_aggregations where parent_id in (Select io.id as output_id from impl_outputs io join impl_aggregations ia on impl_parent_id=ia.id and ia.id in (#{self.child_data_providers.pluck(:id).join(",")}) and io.genre='visits') and split_part(aggregation_level_value,'_',1)='#{year}'"
  end


  def is_eligible?
    return true unless self.genre == "provider"
    return Impl::Aggregation.data_providers.where(name: self.name).count > 0
  end

  def get_data_providers_count_query
    return "Select count(*) as value, '' as key, '' as content, 'Total Institutions' as title, '' as diff_in_value from impl_aggregation_relations where impl_parent_genre='#{self.genre}' and impl_child_genre='data_provider' and impl_parent_id = '#{self.id}'"
  end

  def self.get_providers_hit_list_query
    year = 2015 #Date.today.year
    month = "December" #Date::MONTHNAMES[Date.today.month]
    return "SELECT impl_aggregation_name,'pageviews' as metric,sum,CAST ((diff*1.00/(case when (sum - diff) = 0 then 1 else (sum - diff) end)) * 100 as Decimal(10,4)) as diff_in_value_in_percentage,rank_for_europeana,diff_in_rank_for_europeana,CAST (contribution_to_europeana as Decimal(10,4)) FROM impl_aggregation_rank_of_pageviews where (year='#{year}' and month='#{month}') and (rank_for_europeana <= 25) order by rank_for_europeana;"
  end

  def get_aggregations_count_query(genre=nil)
    return "" if self.genre != 'europeana' and ["country","provider","data_provider"].include?(genre)
    today = Date.today
    return "Select cta.value, '' as key, '' as content, 'Total #{genre.titleize.pluralize}' as title, '' as diff_in_value,io.genre  from impl_outputs io INNER JOIN  core_time_aggregations cta on parent_id = io.id and parent_type = 'Impl::Output' and io.impl_parent_id = 1 and genre = 'top_#{genre}_counts' and split_part(aggregation_level_value,'_',1) = '#{today.year}' and split_part(aggregation_level_value,'_',2) = '#{Date::MONTHNAMES[today.month]}'"
  end

  def get_item_views_query
    return "Select split_part(ta.aggregation_level_value,'_',1) as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o where impl_parent_id = #{self.id}  and genre='item_views') as b  on parent_type='Impl::Output' and parent_id = output_id group by split_part(ta.aggregation_level_value,'_',1) order by split_part(ta.aggregation_level_value,'_',1)"
  end

  #PRIVATE
  private

  def before_create_set
    self.status = "In queue"
    self.name = self.name.strip if self.name.present?
    true
  end

  def after_create_set
    # Aggregations::WikiProfileBuilder.perform_async(self.id)
    if self.genre == 'country'
      Impl::Country::ProviderBuilder.perform_async(self.id)
    end
    Impl::DataProviders::DataSetBuilder.perform_async(self.id)
    Impl::DataProviders::MediaTypesBuilder.perform_async(self.id)
    true
  end
end
