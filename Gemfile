source 'https://rubygems.org'

ruby '2.2.2'

#Base
gem 'rails','4.2.5.2'
gem 'pg'
gem 'redis'
gem 'puma'
gem "haml-rails"
gem "haml"
gem 'devise', '3.5.5'
gem 'friendly_id', '~> 5.0.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem "nestful"
gem "simple_form"
gem 'kaminari'
gem 'carrierwave'
gem 'carrierwave_direct'
gem 'csvlint'
gem 'gon', '~> 5.2.3'
gem 'sidekiq'
gem 'activerecord-session_store'
gem 'redcarpet'
gem 'europeana-styleguide', github: 'europeana/europeana-styleguide-ruby', branch: 'develop'
gem 'stache', github: 'europeana/stache', branch: 'europeana-styleguide' # until upstream merges our pull requests
gem 'dotenv-rails'
gem 'whenever'

#For Sidekiq Web
gem 'redis-namespace'
gem 'sinatra', :require => nil

#Assets related
gem 'uglifier',     '>= 1.3.0'
gem 'sass-rails', '~> 5.0.0'
gem 'susy'

group :doc do
  gem 'sdoc',         '~> 0.4.0'
end

group :production do
  gem 'rails_12factor'
  #For Hosting, Once Richard Comes, we can revert it back to puma
  gem "unicorn"
end

group :development do
  gem "better_errors"
  gem "rails_best_practices"
  gem "binding_of_caller"
  gem 'spring'
  gem 'annotate', ">=2.6.0"
  gem "rails-erd"
  gem 'foreman'
  gem 'rubocop', '~> 0.39.0', require: false
  gem 'rspec-rails', '~> 3.4', '>= 3.4.2'
end
