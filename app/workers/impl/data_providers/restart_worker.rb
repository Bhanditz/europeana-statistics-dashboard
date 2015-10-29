class Impl::DataProviders::RestartWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(data_provider_id)
    data_provider = Impl::Aggregation.data_providers.find(data_provider_id)
    Core::TimeAggregation.where(parent_id: p.impl_outputs.pluck(:id)).delete_all
    Impl::DataProviders::TrafficBuilder.perform_async(p.id)
  end
end