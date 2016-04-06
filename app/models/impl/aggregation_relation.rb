# == Schema Information
#
# Table name: impl_aggregation_relations
#
#  id                :integer          not null, primary key
#  impl_parent_id    :integer
#  impl_parent_genre :string
#  impl_child_id     :integer
#  impl_child_genre  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Impl::AggregationRelation < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregation_relations"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_parent, class_name: "Impl::Aggregation", foreign_key: "impl_parent_id"
  belongs_to :impl_child, class_name: "Impl::Aggregation", foreign_key: "impl_child_id"
  #VALIDATIONS
  validates :impl_parent_id, presence: true
  validates :impl_parent_genre, presence: true, inclusion: {in: ["country","provider"]}
  validates :impl_child_id, presence: true
  validates :impl_child_genre, presence: true, inclusion: {in: ["provider","data_provider"]}

  #CALLBACKS
  #SCOPES
  scope :data_providers, -> {where(impl_child_genre: "data_provider")}
  scope :providers, -> {where(impl_child_genre: "provider")}
  scope :parent_countries, -> {where(impl_parent_genre: "country")}
  scope :parent_providers, -> {where(impl_parent_genre: "provider")}
  #CUSTOM SCOPES
  #FUNCTIONS

  def self.create_or_find(parent_id,parent_genre, child_id, child_genre)
    a = where(impl_parent_id: parent_id, impl_child_id: child_id).first
    if a.nil?
      a = create({impl_parent_id: parent_id, impl_child_id: child_id, impl_parent_genre: parent_genre, impl_child_genre: child_genre})
    end
    a
  end
  #PRIVATE
  private
end
