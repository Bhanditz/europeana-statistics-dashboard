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
#

class Impl::Aggregation < ActiveRecord::Base
  
  #GEMS
  self.table_name = "impl_aggregations"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  has_many :impl_providers, class_name: "Impl::Provider", foreign_key: "impl_aggregation_id"
  
  #ASSOCIATIONS
  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :genre, presence: true
  validates :name, presence: true
  
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private
  
end
