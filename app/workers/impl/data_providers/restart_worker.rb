class Impl::DataProviders::RestartWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.impl_outputs.destroy_all
    Impl::DataProviders::TrafficBuilder.perform_async(aggregation_id)
    Impl::DataProviders::MediaTypesBuilder.perform_async(aggregation_id)
  end
end