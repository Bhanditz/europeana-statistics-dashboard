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
  validates :name, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
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
    return "Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta. aggregation_level_value, '_',2) as quarter, ta.aggregation_value_to_display as x,ta.metric as group, ta.value as y   from core_time_aggregations as ta, (Select o.id as output_id from impl_outputs o where o.impl_parent_id in (Select impl_provider_id from impl_aggregation_providers where impl_aggregation_id = #{self.id}) and genre in ('pageviews','events')) as b where ta.parent_id = b.output_id order by aggregation_index;"
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
    return "Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,ta.value as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o join (Select ip.id from impl_providers ip join impl_aggregation_providers iap on ip.id = iap.impl_provider_id and iap.impl_aggregation_id = #{self.id}) as a on impl_parent_id = a.id and genre='pageviews_line_chart') as b  on parent_type='Impl::Output' and parent_id = output_id"
  end


  def restart_all_jobs
    Aggregations::RestartWorker.perform_async(self.id)
  end

  def top_digital_objects_auto_html
    datacast = self.core_datacasts.top_digital_objects.first
    return "<div id='#{datacast.name.parameterize("_")}' data-datacast_identifier='#{datacast.identifier}' class='top_digital_objects'></div>"
  end


  #PRIVATE
  private

  def before_create_set
    self.status = "In queue"
    true
  end

  def after_create_set
    Aggregations::DatacastsBuilder.perform_async(self.id)
    Aggregations::MediaTypesBuilder.perform_async(self.id)
    Aggregations::WikiProfileBuilder.perform_async(self.id)
    true
  end

end
