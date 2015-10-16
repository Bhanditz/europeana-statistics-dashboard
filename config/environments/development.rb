Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false
  config.active_record.raise_in_transactional_callbacks = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  config.assets.precompile += ['accounts.js', 'core_projects.js', 
                               'core_themes.js', 'data_stores.js', 'vizs.js',"datacast.js", "articles.js", "reports.js", "europeana.css"]

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
    
  BASE_URL = "http://127.0.0.1:3000"
  
  REST_API_ENDPOINT = "http://localhost:9292/v1/"
  
  
  #GA IDS
  GA_CLIENT_ID=ENV["GA_CLIENT_ID"]
  GA_CLIENT_SECRET=ENV["GA_CLIENT_SECRET"]
  GA_SCOPE=ENV["GA_SCOPE"]
  GA_REFRESH_TOKEN=ENV["GA_REFRESH_TOKEN"]
  GA_IDS=ENV["GA_IDS"]
  GA_ENDPOINT = "https://www.googleapis.com/analytics/v3/data/ga"
end
