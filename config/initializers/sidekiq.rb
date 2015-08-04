if Rails.env.production?
  #ENV["REDISTOGO_URL"] ||= 'http://datahub-prod.o5vvnb.0001.apse1.cache.amazonaws.com:6379'
  ENV["REDISTOGO_URL"] ||= 'http://127.0.0.1:6379'
  
  #require 'sidekiq/pro/reliable_push'
  
  Sidekiq.configure_server do |config|
    config.redis = { :url => ENV["REDISTOGO_URL"], :namespace => 'sidekiq' }
    #require 'sidekiq/pro/reliable_fetch'
  end

  Sidekiq.configure_client do |config|
    # Sidekiq::Client.reliable_push!
    config.redis = { :url => ENV["REDISTOGO_URL"], :namespace => 'sidekiq' }
  end
else
    
  #require 'sidekiq/pro/reliable_push'
  
  # Sidekiq.configure_server do |config|
  # end
end