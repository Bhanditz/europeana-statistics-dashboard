# frozen_string_literal: true
redis_url = Rails.application.config_for(:redis).symbolize_keys[:url]

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: 'sidekiq' }
end
