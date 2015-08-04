class Aggregation::RefreshJobWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  require 'jq'
  require 'jq/extend'

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.impl_providers.each {|p| p.refresh_all_jobs}
    Aggregation::MediaTypesBuilder.perform_at(10.seconds.from_now, aggregation_id)
    Aggregation::ReusableBuilder.perform_at(20.seconds.from_now,aggregation_id)
    Aggregation::TrafficAggregator.perform_at(30.seconds.from_now,aggregation_id)
    Aggregation::TopCountriesAggregator.perform_at(40.seconds.from_now,aggregation_id)
    Aggregation::TopDigitalObjectsAggregator.perform_at(50.seconds.from_now,aggregation_id)
  end
end