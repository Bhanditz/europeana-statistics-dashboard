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
#

class Impl::Aggregation < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregations"
  
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
  has_many :impl_data_provider_data_sets,class_name: "Impl::DataProviderDataSet", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :impl_data_sets, through: :impl_data_provider_data_sets
  has_many :impl_aggregation_datacasts, class_name: "Impl::AggregationDatacast", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :core_datacasts, through: :impl_aggregation_datacasts, dependent: :destroy
  has_many :core_vizs, through: :core_datacasts, dependent: :destroy
  has_one :impl_report, class_name: "Impl::Report", foreign_key: "impl_aggregation_id", dependent: :destroy

  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :genre, presence: true, inclusion: {in: ["provider","data_provider","country"]}
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
    if genre == "reusable"
      return "Select key as name, value as weight from impl_static_attributes where impl_output_id in (Select o.id from impl_aggregations a, impl_outputs o where a.id = #{self.id} and o.genre='#{genre}'and o.impl_parent_id = #{self.id})"
    else
      return "Select key as x, value as y from impl_static_attributes where impl_output_id in (Select o.id from impl_aggregations a, impl_outputs o where a.id = #{self.id} and o.genre='#{genre}'and o.impl_parent_id = #{self.id})"
    end
  end

  def get_traffic_query
    return "Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta. aggregation_level_value, '_',2) as quarter, ta.aggregation_value_to_display as x,ta.metric as group, ta.value as y   from core_time_aggregations as ta, (Select o.id as output_id from impl_outputs o where o.impl_parent_id in (Select impl_provider_id from impl_aggregation_providers where impl_aggregation_id = #{self.id}) and genre in ('pageviews_for_traffic','events_for_traffic')) as b where ta.parent_id = b.output_id order by aggregation_index;"
  end

  def get_digital_objects_query
    return "Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta.aggregation_level_value, '_',2) as quarter, ta.aggregation_value_to_display, ta.metric, ta.value,ta.aggregation_index, output_properties -> 'image_url' as image_url, output_properties -> 'title_url' as title_url, output_value as title  from core_time_aggregations ta, (Select o.id as output_id, o.key as output_key, o.value as output_value, o.properties as output_properties from impl_outputs o where o.impl_parent_id in (Select impl_provider_id from impl_aggregation_providers where impl_aggregation_id = #{self.id}) and genre='top_digital_objects') as b where ta.parent_id = b.output_id order by aggregation_index"
  end

  def get_countries_query
    return "Select ta.value as size, b.code as iso2 ,split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta.aggregation_level_value, '_',2) as quarter from core_time_aggregations as ta, (Select o.id as output_id, value, code from impl_outputs o,ref_country_codes as code where o.impl_parent_id in (Select impl_provider_id from impl_aggregation_providers where impl_aggregation_id = #{self.id}) and o.genre='top_countries' and o.value = code.country) as b where ta.parent_id = b.output_id order by aggregation_index;"
  end

  def get_collections_query
    return "Select o.value, o.properties -> 'title' as title, o.properties -> 'content' as content from impl_aggregations a, impl_outputs o where a.id = #{self.id} and o.genre='collections' and o.impl_parent_id = #{self.id}"
  end

  def get_pageviews_line_chart_query
    return "Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o join (Select ip.id from impl_providers ip join impl_aggregation_providers iap on ip.id = iap.impl_provider_id and iap.impl_aggregation_id = #{self.id}) as a on impl_parent_id = a.id and genre='pageviews' and impl_parent_type='Impl::DataSet') as b  on parent_type='Impl::Output' and parent_id = output_id group by ta.aggregation_level_value,aggregation_value_to_display order by split_part(ta.aggregation_level_value,'_',1),to_date(aggregation_value_to_display,'Month');"
  end

  def get_pageviews_top_country_query
    return "Select key,value,properties -> 'title' as title, properties -> 'content' as content from impl_outputs where impl_parent_type = 'Impl::Aggregation' and impl_parent_id = '#{self.id}' and genre='top_pageviews_country';"
  end

  def get_users_top_country_query
    return "Select key,value,properties -> 'title' as title, properties -> 'content' as content from impl_outputs where impl_parent_type = 'Impl::Aggregation' and impl_parent_id = '#{self.id}' and genre='top_users_country';"
  end

  def restart_all_jobs
    Aggregations::RestartWorker.perform_async(self.id)
  end

  def top_digital_objects_auto_html
    datacast = self.core_datacasts.top_digital_objects.first
    return "<div id='#{datacast.name.parameterize("_")}' data-datacast_identifier='#{datacast.identifier}' class='top_digital_objects'></div>"
  end

  def get_aggregated_filters
    filter = "ga:hostname=~europeana.eu;"
    impl_data_sets = self.impl_data_sets
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
    data = JSON.parse(open(query_url).read)['rows']
    if data.present?
      data = data.map{|a| {"month" => a[0], "year"=> a[1], "#{extra_dimension}" => a[2], "#{metric}" => a[3].to_i}}
      data = data.sort_by {|d| [d["year"], d["month"]]}
    end
    return data
  end

  #PRIVATE
  private

  def self.get_current_and_prev_date
    current_date = Date.today.at_beginning_of_month
    prev_date = (current_date - 1)
    return current_date, prev_date
  end

  def before_create_set
    self.status = "In queue"
    self.name = self.name.strip if self.name.present?
    true
  end

  def after_create_set
    # Aggregations::WikiProfileBuilder.perform_async(self.id)
    if self.genre == 'country'
      Impl::Country::ProviderBuilder.perform_at(10.seconds.from_now, self.id)
    elsif self.genre='data_provider'
      Impl::DataProviders::DataSetBuilder.perform_at(10.seconds.from_now, self.id)
    end
    Impl::DataProviders::MediaTypesBuilder.perform_at(10.seconds.from_now,self.id)
    # Impl::DataProviders::DatacastsBuilder.perform_at(10.seconds.from_now,self.id)
    true
  end
end
