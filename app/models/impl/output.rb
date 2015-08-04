# == Schema Information
#
# Table name: impl_outputs
#
#  id               :integer          not null, primary key
#  output           :text
#  genre            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  impl_parent_type :string
#  impl_parent_id   :integer
#  status           :string
#  error_messages   :string
#

class Impl::Output < ActiveRecord::Base
  #GEMS
  self.table_name = 'impl_outputs'

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_parent,polymorphic: :true

  #VALIDATIONS
  validates :impl_parent_id, presence: :true
  validates :impl_parent_type, presence: :true, inclusion: {in: ["Impl::Aggregation","Impl::Provider"]}
  validates :genre, presence: :true
  #CALLBACKS
  #SCOPES
  scope :aggregation_output, -> {where(impl_parent_type: "Impl::Aggregation")}
  scope :provider_output, -> {where(impl_parent_type: "Impl::Provider")}
  scope :traffic, -> {where(genre: "traffic")}
  scope :top_25_countries, -> {where(genre: "top_25_countries")}
  scope :top_10_digital_objects, -> {where(genre: "top_10_digital_objects")}
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.find_or_create(impl_parent_id,impl_parent_type,genre)
    a = where(impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre).first
    if a.blank?
      a = create({impl_parent_id: impl_parent_id,impl_parent_type: impl_parent_type,genre: genre})
    end
    a 
  end
  #PRIVATE
  private
end
