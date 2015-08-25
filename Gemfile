source 'https://rubygems.org'

ruby '2.2.2'

#Base
gem 'rails',        '4.2.1'
gem 'pg'
gem 'redis'
gem 'jbuilder',     '~> 2.0' # Build JSON APIs with ease.
gem 'unicorn'
gem "haml-rails"
gem "haml"
gem 'devise'
gem 'json_pure'
gem 'friendly_id', '~> 5.0.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem "nestful"
gem "simple_form", git: "https://github.com/plataformatec/simple_form.git"
gem 'kaminari'
gem 'best_in_place', git: "https://github.com/bernat/best_in_place.git"
gem 'aws-sdk'
gem "aws-sdk-core"
gem "git"
gem "switch_user"
#gem "aws-s3", :require => "aws/s3"
gem "jquery-fileupload-rails"
gem "rmagick", "2.13.4"
gem 'carrierwave'
gem 'carrierwave_direct'
gem 'csvlint'
gem 'gon', '~> 5.2.3'
gem 'ruby-jq', '0.1.6'

gem 'activerecord-session_store'
gem 'aescrypt'

#Europeana Style Guide Gem

gem 'europeana-api'

#gem 'europeana-styleguide', git: 'https://github.com/europeana/europeana-styleguide-ruby'

#-WORKERS_SYSTEM
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem "slim"

#NLP / Text Analytics
gem "punkt-segmenter"
gem "chronic" #date NLP

#Assets related
gem 'sass-rails',   '~> 4.0.3'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

#external APIs
gem "rest-client"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

group :doc do
  gem 'sdoc',         '~> 0.4.0'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'spring'
  gem 'annotate', ">=2.6.0"
  #gem "bullet"
  gem "rails-erd"
end

group :production do
  gem 'newrelic_rpm'
  gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"
  #gem 'rails_12factor'
end
gem 'open4'
