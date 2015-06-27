if Rails.env.production?
  require 'raven'
  #require 'raven/sidekiq'
  Raven.configure do |config|
    config.dsn = 'https://f93402be75094e34aa35c5741354ddd8:c6a4faeb335d4955b4262bea0ad3b5e3@app.getsentry.com/26767'
  end
end

