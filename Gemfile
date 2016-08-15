source 'https://rubygems.org'

gem 'rails','4.2.7.1'

#Base
gem 'pg'
gem 'redis'
gem 'puma'
gem "haml-rails"
gem "haml"
gem 'devise'
gem 'friendly_id', '~> 5.0.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem "nestful"
gem "simple_form"
gem 'kaminari'
gem 'gon'
gem 'sidekiq'
gem 'activerecord-session_store'
gem 'redcarpet'
gem 'europeana-styleguide', github: 'europeana/europeana-styleguide-ruby',  ref: 'f1cc2b5'
gem 'stache', github: 'europeana/stache', branch: 'europeana-styleguide'# until upstream merges our pull requests
gem 'dotenv-rails'
gem 'whenever'
gem "redis-namespace"
gem 'nokogiri', '>= 1.6.8'


#Assets related
gem 'uglifier',     '>= 1.3.0'
gem 'sass-rails', '~> 5.0.0'
gem 'susy'


group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem "better_errors"
  gem "rails_best_practices"
  gem "binding_of_caller"
  gem 'spring'
  gem 'annotate', ">=2.6.0"
  gem "rails-erd"
  gem 'foreman'
  gem 'rubocop', '~> 0.39.0', require: false
  gem 'rspec-rails', '~> 3.4', '>= 3.4.2'
  gem 'coveralls', require: false
  gem 'simplecov', :require => false, :group => :test
  gem 'yard'
  gem 'seed_dump'
end
