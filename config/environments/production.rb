Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  #config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += ['accounts.js', 'core_projects.js', 
                               'core_themes.js', 'data_stores.js', 'vizs.js', 'maps.js','embed.js',"datacast.js"]
  
  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  
  config.action_mailer.default_url_options = { host: 'https://rumi.io' }
    
  # TWITTER_KEY = "rmxZ5kj7PW61VoNufB1l0lewd"
  # TWITTER_SECRET = "jCKjjx0vqtHf1UgcH0yibwZwpyIb0wSUpeLacfroCdPAQTwI0C"
  TWITTER_KEY = "rmxZ5kj7PW61VoNufB1l0lewd"
  TWITTER_SECRET = "jCKjjx0vqtHf1UgcH0yibwZwpyIb0wSUpeLacfroCdPAQTwI0C"  
  
  GOOGLE_CLIENT_ID = "808566179623-b6dbetd82hus0uqeg4q6edod4tnvnh2c.apps.googleusercontent.com"
  GOOGLE_CLIENT_SECRET = "8htXEZTBUpLPsx9qskSt4kdY"
  GOOGLE_KEY = "AIzaSyCHlyZhIW64BAxEtiJlgvpke-JbUjOC_0c"
  FREEBASE_ENV = "v1"
  
  #REDIS_HOST = "datahub-app.o5vvnb.0001.apse1.cache.amazonaws.com"
  REDIS_HOST = "127.0.0.1"
  REDIS_PORT = 6379
  
  REST_API_ENDPOINT = "https://api.rumi.io/v1/"
  
  #Object Storage Constants
  SOFTLAYER_CONTAINER_NAME  = "rumi.io"

  FULLCONTACT = "17876551158a3d4c"
  CALLBACK_URL = "https://rumi.io"
  
  BASE_URL = 'https://rumi.io'
  
  #redis_client = Redis.new(:url => "redis://user:PASSWORD@datahub-development.wdzjlu.0001.usw2.cache.amazonaws.com")
  #Resque.redis = redis_client
  # Logo Bucket
  S3_BUCKET_LOGO = "rumi.logos"

  ActionMailer::Base.delivery_method = :smtp
  
  ActionMailer::Base.smtp_settings = {
    :user_name => "sendgrid_rumi_production",
    :password => 'indianmonsoon1234801',
    :domain => 'rumi.io',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  ActionMailer::Base.default_options = {
    :from => "Rumi.io DataHub <rumi@pykih.com>"
  }
end
