# == Schema Information
#
# Table name: impl_outputs
#
#  id               :integer          not null, primary key
#  genre            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  impl_parent_type :string
#  impl_parent_id   :integer
#  status           :string
#  error_messages   :string
#  key              :string
#  value            :string
#  properties       :hstore
#

class Impl::Output < ActiveRecord::Base
  #GEMS
  self.table_name = 'impl_outputs'

  #CONSTANTS
  #ATTRIBUTES
  attr_accessor :skip_uniqueness_validation
  #ACCESSORS
  store_accessor :properties, :image_url, :title_url, :title, :content
  #ASSOCIATIONS
  belongs_to :impl_parent,polymorphic: :true
  has_many :core_time_aggregations,->{where(parent_type: 'Impl::Output')} ,class_name: "Core::TimeAggregation", foreign_key: "parent_id", dependent: :destroy
  has_many :country_code, class_name: "Ref::CountryCode", primary_key: "value", foreign_key: "country"
  #VALIDATIONS
  validates :impl_parent_id, presence: :true
  validates :impl_parent_type, presence: :true, inclusion: {in: ["Impl::Aggregation","Impl::Dataset"]}
  validates :genre, presence: :true
  validates :value, uniqueness: {scope: [:key, :impl_parent_id, :impl_parent_type, :genre]}, allow_blank: true, allow_nil: true, unless: :skip_uniqueness_validation

  #CALLBACKS
  #SCOPES
  scope :media_types, -> {where(genre: "media_types" )}
  scope :reusable, -> {where(genre: "reusable")}
  scope :top_digital_objects, -> {where(genre: "top_digital_objects")}
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.find_or_create(impl_parent_id,impl_parent_type,genre,options={})
    unless options.blank?
      a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre,key: options[:key], value: options[:value]).first
    else
      a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre).first
    end
    if a.blank?
      a = create({impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre, key: options[:key], value: options[:value]})
    end
    a
  end

  def self.update_with_custom_attributes(impl_parent_id, impl_parent_type,options={})
    a = Impl::Output.find_or_create_digital_object(impl_parent_id,impl_parent_type,options)
    a.image_url = options[:image_url]
    a.properties_will_change!
    a.save
    return a
  end

  def self.find_or_create_digital_object(impl_parent_id, impl_parent_type,options={})
    a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: "top_digital_objects", key: options[:key], value: options[:value]).where("properties -> 'title_url' = ?", options[:title_url]).first
    if a.blank?
      a = create({impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: "top_digital_objects", key: options[:key], value: options[:value],title_url: options[:title_url],skip_uniqueness_validation: true})
    end
    return a
  end


  #PRIVATE
  private
end
