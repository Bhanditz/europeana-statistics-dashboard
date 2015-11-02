# == Schema Information
#
# Table name: core_time_aggregations
#
#  id                             :integer          not null, primary key
#  aggregation_level              :string
#  parent_type                    :string
#  parent_id                      :integer
#  aggregation_level_value        :string
#  metric                         :string
#  value                          :integer
#  difference_from_previous_value :integer
#  is_positive_value              :boolean
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  aggregation_index              :integer
#  aggregation_value_to_display   :string
#

class Core::TimeAggregation < ActiveRecord::Base
  #GEMS
  self.table_name = "core_time_aggregations"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :parent,polymorphic: :true
  #VALIDATIONS
  validates :parent_type, presence: :true
  validates :parent_id, presence: :true
  validates :aggregation_level, presence: :true
  validates :aggregation_level_value, presence: :true
  validates :metric, presence: :true
  validates :value, presence: :true

  #CALLBACKS
  before_create :before_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.create_time_aggregations(parent_type,parent_id,data,metric,aggregation_level)
    if data.size > 0
      data.each do |d|
        value = d[metric]
        month = d["month"]
        year  = d["year"]
        aggregation_level_value = Core::TimeAggregation.fetch_aggregation_value(aggregation_level,year,month)
        time_aggregation = Core::TimeAggregation.create_or_update(parent_type, parent_id, metric, aggregation_level, aggregation_level_value, value)
      end
    end
  end

  def self.create_or_update(parent_type, parent_id, metric, aggregation_level, aggregation_level_value, value)
    a = where(parent_type: parent_type, parent_id: parent_id, metric: metric, aggregation_level: aggregation_level,aggregation_level_value: aggregation_level_value).first
    if a.blank?
      a = create({parent_type: parent_type, parent_id: parent_id, metric: metric, aggregation_level: aggregation_level,aggregation_level_value: aggregation_level_value, value: value})
    else
      new_value = a.value.to_f + value
      if a.aggregation_index > 1
        prev = where(parent_type: parent_type,parent_id: parent_id, aggregation_level: aggregation_level, metric: metric, aggregation_index: a.aggregation_index - 1).first
        diff = new_value - prev.value
      else
        diff = 0
      end
      a.update(value: new_value, difference_from_previous_value: diff.abs, is_positive_value: (diff > 0))
    end
    a
  end

  def self.fetch_aggregation_value(aggregation_level,year,month,options={})
    case aggregation_level
      when "weekly"
        week = options[:week]
        aggregation_value = "#{year}_W#{week}"
      when "quarterly"
        quarter = ((month.to_i - 1)/3) + 1
        aggregation_value = "#{year}_Q#{quarter}"
      when "monthly"
        aggregation_value = "#{year}_#{Date::MONTHNAMES[month.to_i]}"
      when "half_yearly"
        half = ((month.to_i - 1)/6) + 1
        aggregation_value = "#{year}_H#{half}"
      when "yearly"
        aggregation_value = "#{year}"
    end
    return aggregation_value
  end

  def self.create_aggregations(data,aggregation_level,parent_id,parent_type,metric,output_type)
    if data.size > 0
      data.each do |c|
        parent_output = Impl::Output.find_or_create(parent_id,parent_type,"top_#{output_type.pluralize}",key: output_type,value: c[output_type])
        month = c["month"]
        year  = c["year"]
        value = c[metric]
        aggregation_level_value = Core::TimeAggregation.fetch_aggregation_value(aggregation_level,year,month)
        time_aggregation = Core::TimeAggregation.create_or_update("Impl::Output", parent_output.id, metric, aggregation_level, aggregation_level_value, value)
      end
    end
  end

  def self.create_digital_objects_aggregation(digital_objects_data,aggregation_level, data_provider_id)
    digital_objects_data.each do |d|
      digital_objects_output = Impl::Output.update_with_custom_attributes(data_provider_id,"Impl::Aggregation","top_digital_objects", d["title_url"],d["image_url"],key: "title", value: d["title"])
      month = d["month"]
      year  = d["year"]
      value = d["size"]
      aggregation_level_value = Core::TimeAggregation.fetch_aggregation_value(aggregation_level,year,month)
      time_aggregation = Core::TimeAggregation.create_or_update("Impl::Output", digital_objects_output.id, "pageviews", aggregation_level, aggregation_level_value, value)
    end
  end
  
  #PRIVATE
  private


  def before_create_set
    previous = Core::TimeAggregation.where(parent_type: self.parent_type,parent_id: self.parent_id, aggregation_level: self.aggregation_level, metric: self.metric).order(:aggregation_index).last
    if previous.blank?
      self.aggregation_index = 1
    else
      self.aggregation_index = previous.aggregation_index + 1
      diff = (previous.value - self.value).to_i
      self.difference_from_previous_value = diff.abs
      self.is_positive_value = (diff < 0)
    end
    self.aggregation_value_to_display = self.aggregation_value_to_display.blank? ? self.aggregation_level_value.split("_")[1] : self.aggregation_level_value
    true
  end
end
