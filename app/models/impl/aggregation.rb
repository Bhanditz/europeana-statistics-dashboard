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
#  provider_ids      :string           default([]), is an Array
#  status            :string
#  error_messages    :string
#

class Impl::Aggregation < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregations"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  has_many :impl_providers, class_name: "Impl::Provider", foreign_key: "impl_aggregation_id", dependent: :destroy
  has_many :impl_aggregation_outputs,-> {aggregation_output},class_name: "Impl::Output", foreign_key: "impl_parent_id", dependent: :destroy
  has_many :impl_provider_outputs, through: :impl_providers
  #ASSOCIATIONS
  #VALIDATIONS
  validates :core_project_id, presence: true
  validates :genre, presence: true
  validates :name, presence: true
  validates :provider_ids, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def refresh_all_jobs
    Aggregation::RefreshJobWorker.perform_async(self.id)
  end
  #PRIVATE
  private

  def before_create_set
    true
  end

  def after_create_set
    if self.provider_ids.count > 0
      self.provider_ids.each do |p|
        Impl::Provider.create(provider_id: p,impl_aggregation_id: self.id)
      end
    end
    Impl::AggregationOutput.create(impl_aggregation_id: a.id)
    true
  end

end