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
  #ACCESSORS
  store_accessor :properties, :image_url, :title_url
  #ASSOCIATIONS
  belongs_to :impl_parent,polymorphic: :true
  has_many :impl_static_attributes, class_name: "Impl::StaticAttribute", foreign_key: "impl_output_id", dependent: :destroy
  has_many :core_time_aggregations,->{where(parent_type: 'Impl::Output')} ,class_name: "Core::TimeAggregation", foreign_key: "parent_id", dependent: :destroy
  has_many :country_code, class_name: "Ref::CountryCode", primary_key: "value", foreign_key: "country"
  #VALIDATIONS
  validates :impl_parent_id, presence: :true
  validates :impl_parent_type, presence: :true, inclusion: {in: ["Impl::Aggregation","Impl::Provider"]}
  validates :genre, presence: :true
  validates :value, uniqueness: {scope: [:key, :impl_parent_id, :impl_parent_type]}, allow_blank: true, allow_nil: true

  #CALLBACKS
  #SCOPES
  scope :aggregation_output, -> {where(impl_parent_type: "Impl::Aggregation")}
  scope :provider_output, -> {where(impl_parent_type: "Impl::Provider")}
  scope :collections, -> {where(genre: "collections" )}
  scope :media_types, -> {where(genre: "media_types" )}
  scope :reusable, -> {where(genre: "reusable")}
  scope :traffic, -> {where(genre: ["pageviews","events"])}
  scope :top_countries, -> {where(genre: "top_countries" )}
  scope :top_digital_objects, -> {where(genre: "top_digital_objects")}
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.find_or_create(impl_parent_id,impl_parent_type,genre,options={})
    a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre,key: options[:key], value: options[:value]).first
    if a.blank?
      a = create({impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre, key: options[:key], value: options[:value]})
    end
    a 
  end

  def self.update_with_custom_attributes(impl_parent_id, impl_parent_type, genre,title_url, image_url, options={})
    a = Impl::Output.find_or_create(impl_parent_id,impl_parent_type,genre,options)
    a.title_url = title_url
    a.image_url = image_url
    a.properties_will_change!
    a.save!
    return a
  end

  #PRIVATE
  private
end
