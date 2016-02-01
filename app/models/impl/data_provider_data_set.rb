# == Schema Information
#
# Table name: impl_data_provider_data_sets
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  impl_data_set_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::DataProviderDataSet < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_data_provider_data_sets"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_data_provider, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  belongs_to :impl_data_set, class_name: "Impl::DataSet", foreign_key: "impl_data_set_id"
  #VALIDATIONS
  validates :impl_data_set_id, presence: :true
  validates :impl_aggregation_id, presence: :true, uniqueness: {scope: :impl_data_set_id}

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
  private

  def before_create_set
    true
  end

  def after_create_set
    true
  end
end
