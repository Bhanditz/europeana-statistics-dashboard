$redis = Redis.new(Rails.application.config_for(:redis).symbolize_keys)
