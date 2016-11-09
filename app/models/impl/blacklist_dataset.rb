# frozen_string_literal: true
class Impl::BlacklistDataset < ActiveRecord::Base
  # GEMS
  self.table_name = 'impl_blacklist_datasets'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  # VALIDATIONS
  validates :dataset, presence: true, uniqueness: true
  # CALLBACKS
  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS

  # Returns the list of blacklisted datasets and caches the blacklist in redis.
  def self.get_blacklist_datasets
    if Rails.cache.fetch('blacklist_datasets')
      blacklist_datasets = JSON.parse(Rails.cache.fetch('blacklist_datasets'))
    else
      blacklist_datasets = all.pluck(:dataset)
      Rails.cache.fetch('blacklist_datasets') { blacklist_datasets }
    end
    blacklist_datasets
  end
  # PRIVATE
end
