# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'net/ftp'
require 'susy'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Europeana
  module StatisticsDashboard
    class Application < Rails::Application
      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      config.time_zone = 'UTC'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      config.i18n.default_locale = :en
      config.serve_static_files = true

      # Making active record the default for database migrations instead of mongo
      config.generators do |g|
        g.orm :active_record
      end

      # hstore
      # config.active_record.schema_format = :sql

      ActiveRecord::SessionStore::Session.table_name = 'core_sessions'
      ActiveRecord::SessionStore::Session.primary_key = 'session_id'
      ActiveRecord::SessionStore::Session.data_column_name = 'data'

      # Load Redis config from config/redis.yml, if it exists
      config.cache_store = begin
        redis_config = Rails.application.config_for(:redis).symbolize_keys
        fail RuntimeError unless redis_config.present?
        puts "set redis in application.rb"
        [:redis_store, redis_config[:url]]
      rescue RuntimeError => e
        puts "Unable to set redis as cache, using :null_store"
        :null_store
      end

      # Load Action Mailer SMTP config from config/smtp.yml, if it exists
      config.action_mailer.smtp_settings = begin
        Rails.application.config_for(:smtp).symbolize_keys
      rescue RuntimeError
        {}
      end
    end
  end
end
