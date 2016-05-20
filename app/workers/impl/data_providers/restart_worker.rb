class Impl::DataProviders::RestartWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_column(:last_updated_at, nil)
    aggregation.impl_outputs.destroy_all
    Impl::DataProviders::DataSetBuilder.perform_async(aggregation.id)
    Impl::DataProviders::MediaTypesBuilder.perform_async(aggregation_id)
    Impl::Country::ProviderBuilder.perform_async(aggregation.id) if aggregation.genre == "country"
  end
end