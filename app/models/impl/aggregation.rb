# == Schema Information
#
# Table name: impl_aggregations
#
#  id                :integer          not null, primary key
#  core_project_id   :integer
#  genre             :string
#  name              :string
#  wikiname          :string
#  created_by        :integer
#  updated_by        :integer
#  last_requested_at :integer
#  last_updated_at   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  status            :string
#  error_messages    :string
#  properties        :hstore
#  country           :string
#

class Impl::Aggregation < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregations"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :wikipedia_content
  #ASSOCIATIONS
  has_many :impl_aggregation_providers, class_name: "Impl::AggregationProvider", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :impl_providers, through: :impl_aggregation_providers
  has_many :impl_aggregation_outputs,-> {aggregation_output},class_name: "Impl::Output", foreign_key: "impl_parent_id", dependent: :destroy
  has_many :impl_provider_outputs, through: :impl_providers
  has_many :impl_aggregation_datacasts, class_name: "Impl::AggregationDatacast", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :core_datacasts, through: :impl_aggregation_datacasts, dependent: :destroy
  has_many :core_vizs, through: :core_datacasts, dependent: :destroy
  has_one :impl_report, class_name: "Impl::Report", foreign_key: "impl_aggregation_id", dependent: :destroy

  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :genre, presence: true
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  scope :aggregations, -> {where(genre: ["provider","data_provider"])}
  scope :no_country, -> {where(country: nil)}
  scope :country, ->{no_country.where(genre: "country")}
  scope :europeana, -> {no_country.where(genre: "europeana").first}
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
    return "Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o join (Select ip.id from impl_providers ip join impl_aggregation_providers iap on ip.id = iap.impl_provider_id and iap.impl_aggregation_id = #{self.id}) as a on impl_parent_id = a.id and genre='pageviews' and impl_parent_type='Impl::Provider') as b  on parent_type='Impl::Output' and parent_id = output_id group by ta.aggregation_level_value,aggregation_value_to_display order by split_part(ta.aggregation_level_value,'_',1),to_date(aggregation_value_to_display,'Month');"
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
    impl_providers = self.impl_providers
    last_id = impl_providers.last.id
    impl_providers.each do |p|
      filter += "ga:pagePath=~/#{p.provider_id.strip}/#{p.id == last_id ? "" : ","}"
    end
    return filter
  end

  def europeana?
    return self.genre == "europeana"
  end

  def get_aggregation_ranking_query
    current_date, prev_date = Impl::Aggregation.get_current_and_prev_date
    return "Select metric,sum as value_of_last_month, diff as diff_value,CAST (contribution_to_europeana as Decimal(10,4)),rank_for_europeana, diff_in_rank_for_europeana from impl_aggregation_ranks where impl_aggregation_id=#{self.id} and ((metric='pageviews' and (year='#{prev_date.year}' and month='#{Date::MONTHNAMES[prev_date.month]}')) or metric='collections')"
  end

  def get_top_providers_query(maximum_rank=3)
    current_date, prev_date = Impl::Aggregation.get_current_and_prev_date
    return "SELECT impl_aggregation_name,metric,sum,CAST ((diff*1.00/(sum - diff)) * 100 as Decimal(10,4)) as diff_in_value_in_percentage,rank_for_europeana,diff_in_rank_for_europeana,CAST (contribution_to_europeana as Decimal(10,4)) FROM impl_aggregation_ranks where ((year='#{prev_date.year}' and month='#{Date::MONTHNAMES[prev_date.month]}') or (year='N/A' and month='N/A')) and (rank_for_europeana <= #{maximum_rank}) order by metric, rank_for_europeana"
  end

  def self.create_or_find_country_report(country, genre, core_project_id)
    country_report = where(name:country, genre: genre, core_project_id: core_project_id).first
    if country_report.nil?
      country_report = create({name: country, genre: genre, wikiname: nil,core_project_id: core_project_id, status: "Building Country Report"})
    end
    country_report
  end

  def get_media_for_visits_query
    return "Select sum(value) as weight, name, split_part(aggregation_level_value,'_',1) as year from core_time_aggregations cta join (Select io.id as impl_output_id, value as name from impl_outputs io join impl_aggregations ia on io.impl_parent_id=ia.id and io.impl_parent_type ='Impl::Aggregation' and ia.name='Europeana' and io.genre='top_media') as impl_aggregation_output on parent_id = impl_output_id and parent_type='Impl::Output' group by name,split_part(aggregation_level_value,'_',1) order by split_part(aggregation_level_value,'_',1)"
  end


  def self.get_europeana_query(metric)
    return "Select sum(value) as y,split_part(aggregation_level_value,'_',1) as x from core_time_aggregations cta join (select io.id as impl_output_id from impl_outputs io join impl_aggregations ia on io.impl_parent_id = ia.id and io.impl_parent_type='Impl::Aggregation' and ia.genre='europeana' and io.genre='#{metric}') as iao on cta.parent_id = iao.impl_output_id and cta.parent_type='Impl::Output' group by metric, split_part(aggregation_level_value,'_',1) order by split_part(aggregation_level_value,'_',1)"
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
    true
  end

  def after_create_set
    if ["provider","data_provider"].include?(genre)
      Aggregations::MediaTypesBuilder.perform_async(self.id)
      Aggregations::WikiProfileBuilder.perform_async(self.id)
      Aggregations::DatacastsBuilder.perform_async(self.id)
    end
    true
  end
end