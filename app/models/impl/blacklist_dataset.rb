class Impl::BlacklistDataset < ActiveRecord::Base
	#GEMS
  self.table_name = "impl_blacklist_datasets"

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  #VALIDATIONS
  validates :dataset, presence: true, uniqueness: true
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS

  def self.get_backlist_datasets
  	if $redis.get("blacklist_datasets")
  		blacklist_datasets = JSON.parse($redis.get("blacklist_datasets"))
  	else
  		blacklist_datasets = self.all.pluck(:dataset)
  		$redis.set("blacklist_datasets", blacklist_datasets)
  	end
  	blacklist_datasets
  end
  #PRIVATE
  private
end
