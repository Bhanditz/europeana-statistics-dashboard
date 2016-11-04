# frozen_string_literal: true
# == Schema Information
#
# Table name: impl_datasets
#
#  id                  :integer          not null, primary key
#  data_set_id         :string
#  created_by          :integer
#  updated_by          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :string
#  error_messages      :string
#  impl_aggregation_id :integer
#  name                :string
#

class Impl::DataSet < ActiveRecord::Base
  # GEMS
  self.table_name = 'impl_datasets'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  has_many :impl_aggregation_data_sets, class_name: 'Impl::AggregationDataSet', foreign_key: 'impl_data_set_id', dependent: :destroy
  has_many :impl_aggregations, through: :impl_aggregation_data_sets
  # VALIDATIONS
  validates :name, presence: :true, uniqueness: true
  validates :data_set_id, uniqueness: true

  # CALLBACKS
  before_create :before_create_set
  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS

  # Returns the access token and refreshes the access token if it has expired.
  def self.get_access_token
    if $redis.get('ga_access_token').present?
      a = $redis.get('ga_access_token')
    else
      resp = Nestful.post 'https://accounts.google.com/o/oauth2/token', method: 'POST', grant_type: 'refresh_token', refresh_token: GA_REFRESH_TOKEN.to_s, client_id: GA_CLIENT_ID.to_s, client_secret: GA_CLIENT_SECRET.to_s
      a = JSON.parse(resp.body)['access_token']
      $redis.set('ga_access_token', a)
      $redis.expire('ga_access_token', 60 * 60)
    end
    a
  end

  # Either creates a new Impl::DataSet or returns an existing Impl::DataSet object from the database.
  #
  # @param data_set_name [String] name of the dataset.
  # @return [Object] a reference to Impl::DataSet.
  def self.find_or_create(data_set_name)
    a = where(name: data_set_name).first
    if a.blank?
      a = new(name: data_set_name)
      a.save
    end
    a
  end
  # PRIVATE

  private

  def before_create_set
    self.status = 'In queue'
    self.data_set_id = name.split('_')[0].gsub(/[^0-9,.]/, '')
    true
  end
end
