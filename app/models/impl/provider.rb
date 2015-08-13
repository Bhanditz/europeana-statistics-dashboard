# == Schema Information
#
# Table name: impl_providers
#
#  id             :integer          not null, primary key
#  provider_id    :string
#  created_by     :integer
#  updated_by     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  status         :string
#  error_messages :string
#

class Impl::Provider < ActiveRecord::Base
  
  #GEMS
  self.table_name = "impl_providers"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  has_many :impl_aggregation_providers, class_name: "Impl::AggregationProvider", foreign_key: "impl_provider_id", dependent: :destroy
  has_many :impl_provider_outputs,->{provider_output} ,class_name: "Impl::Output", foreign_key: "impl_parent_id", dependent: :destroy

  #VALIDATIONS
  validates :provider_id, presence: :true,uniqueness: true

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def self.get_access_token
    if $redis.get("ga_access_token").present?
      a = $redis.get("ga_access_token")
    else
      a = JSON.parse((Nestful.post("https://accounts.google.com/o/oauth2/token?method=POST&grant_type=refresh_token&refresh_token=#{GA_REFRESH_TOKEN}&client_id=#{GA_CLIENT_ID}&client_secret=#{GA_CLIENT_SECRET}")).body)['access_token']
      $redis.set("ga_access_token", a)
      $redis.expire("ga_access_token", 60*60)
    end
    a
  end

  def refresh_all_jobs
    end_date = Date.today.at_beginning_of_week.strftime("%Y-%m-%d")
    start_date = (Date.today.at_beginning_of_week - 1).at_beginning_of_week.strftime("%Y-%m-%d")
    Impl::TrafficBuilder.perform_async(self.id,start_date,end_date)
  end

  def self.find_or_create(provider_id, created_by=nil, updated_by=nil)
    a = where(provider_id: provider_id).first
    if a.blank?
      a = create({provider_id: provider_id, created_by: created_by, updated_by: updated_by})
    end
    a
  end
  #PRIVATE
  private

  def before_create_set
    self.status = "In queue"
    true
  end

  def after_create_set
    Impl::TrafficBuilder.perform_async(self.id)
    true
  end
  
end
