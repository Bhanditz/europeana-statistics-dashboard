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
#

class Impl::Output < ActiveRecord::Base
  #GEMS
  self.table_name = 'impl_outputs'

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_parent,polymorphic: :true
  has_many :impl_static_attributes, class_name: "Impl::StaticAttribute", foreign_key: "impl_output_id", dependent: :destroy
  has_many :country_code, class_name: "Ref::CountryCode", primary_key: "value", foreign_key: "country"
  #VALIDATIONS
  validates :impl_parent_id, presence: :true
  validates :impl_parent_type, presence: :true, inclusion: {in: ["Impl::Aggregation","Impl::Provider"]}
  validates :genre, presence: :true
  validates :value, uniqueness: {scope: :key}, allow_blank: true, allow_nil: true

  #CALLBACKS
  #SCOPES
  scope :aggregation_output, -> {where(impl_parent_type: "Impl::Aggregation")}
  scope :provider_output, -> {where(impl_parent_type: "Impl::Provider")}
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.find_or_create(impl_parent_id,impl_parent_type,genre,options={})
    a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre,key: options[:key], value: options[:value]).first
    if a.blank?
      a = create({impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre, key: options[:key], value: options[:value]})
    end
    a 
  end

  #PRIVATE
  private
end
