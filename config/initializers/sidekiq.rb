redis_url = Rails.application.config_for(:redis).symbolize_keys[:url]

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url, :namespace => 'sidekiq' }
  #require 'sidekiq/pro/reliable_fetch'
end

Sidekiq.configure_client do |config|
  # Sidekiq::Client.reliable_push!
  config.redis = { :url => redis_url, :namespace => 'sidekiq' }
end
