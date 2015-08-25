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
    
  #TWITTER_KEY = "eTEJz6y7jCFwJ3UeJI6wZ7FP0"
  #TWITTER_SECRET = "jWWuAEruPiwRI0wOqY1XxRTZrQI2VwUXOLq0kEIee3ihAIOKp7"
  TWITTER_KEY = "rmxZ5kj7PW61VoNufB1l0lewd"
  TWITTER_SECRET = "jCKjjx0vqtHf1UgcH0yibwZwpyIb0wSUpeLacfroCdPAQTwI0C"
  
  GOOGLE_CLIENT_ID = "79004200365-5li5h1tcuien4t09kkkprntvds5a7tnf.apps.googleusercontent.com"
  GOOGLE_CLIENT_SECRET = "HZv7RyzgUC67gaZmCCLxy2N2"
  GOOGLE_KEY = "AIzaSyCHlyZhIW64BAxEtiJlgvpke-JbUjOC_0c"
  FREEBASE_ENV = "v1sandbox"
  
  FULLCONTACT = "9955794aff22dda6"
  CALLBACK_URL = "http://pykih.pykih.ultrahook.com"
  
  BASE_URL = "http://127.0.0.1:3000"
  
  #redis_client = Redis.new(:url => "redis://user:PASSWORD@datahub-development.wdzjlu.0001.usw2.cache.amazonaws.com")
  #Resque.redis = redis_client
  
  REST_API_ENDPOINT = "http://localhost:9292/v1/"
  
  REDIS_HOST = "localhost"
  REDIS_PORT = 6379

  #Object Storage Constants
  SOFTLAYER_CONTAINER_NAME  = "rumi.io.local"
  # Logo Bucket
  S3_BUCKET_LOGO = "rumi.logos.local"


  #GA IDS
  GA_CLIENT_ID = "599221898843-7oc1qsiruqh65iemmq45oceck0kp1g49.apps.googleusercontent.com"
  GA_CLIENT_SECRET = "-_VGYZBgcqf1ju1poeuDn3gJ"
  GA_SCOPE = "https://www.googleapis.com/auth/analytics"
  GA_REFRESH_TOKEN = "1/ATA4d0qo-2q5j9N4Mw-f0uRgt-wH_UGMrl1G62zvWeg"
  GA_IDS = "25899454"
  GA_ENDPOINT = "https://www.googleapis.com/analytics/v3/data/ga"

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :user_name => "sendgrid_rumi_local",
    :password => 'indianmonsoon1234801',
    :domain => 'localhost:3000',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
  
  ActionMailer::Base.default_options = {
    :from => "Rumi.io DataHub Local <rumi-local@pykih.com>"
  }


  
  if 1 == 2
    #https://github.com/flyerhzm/bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.console = true
      #Bullet.xmpp = { :account  => '64187_912489@chat.hipchat.com', :password => 'westernsnow123', :receiver => '64187_pykih_software_llp@conf.hipchat.com', :show_online_status => true }
      Bullet.add_footer = true
      #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
      Bullet.alert = false
      Bullet.growl = false
      Bullet.airbrake = false
      Bullet.rails_logger = false
      Bullet.bugsnag = false
    end
  end
  
end
