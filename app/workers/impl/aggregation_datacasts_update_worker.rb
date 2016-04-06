class Impl::AggregationDatacastsUpdateWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(provider_id)
    provider = Impl::Provider.find(provider_id)
    begin
      impl_aggregations = provider.impl_aggregations
      impl_aggregations.each do |aggregation|
        aggregation.core_datacasts.each do |d|
          Core::Datacast::RunWorker.perform_async(d.id)
        end
      end
    rescue => e
    end
  end
end