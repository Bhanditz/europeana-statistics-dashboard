class Aggregations::RestartWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    begin
      aggregation.impl_providers.each do |p|
        Impl::TrafficBuilder.perform_async(p.id)
        sleep 30
      end
    rescue => e
      aggregation.update_attributes(status: "Failed to Restart all Jobs", error_messages: e.to_s)
    end
  end
end