# frozen_string_literal: true
source 'https://rubygems.org'

gem 'rails', '4.2.7.1'

# NB: this *must* be by Git ref; else will break asset versioning in
#     config/initializers/assets.rb, preventing app startup
gem 'europeana-styleguide', github: 'europeana/europeana-styleguide-ruby', ref: 'f1cc2b5'

# Use a forked version of stache with downstream changes, until merged upstream
# @see https://github.com/agoragames/stache/pulls/rwd
gem 'stache', github: 'europeana/stache', branch: 'europeana-styleguide'

gem 'activerecord-session_store'
gem 'clockwork'
gem 'devise'
gem 'friendly_id', '~> 5.0.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+
gem 'gon'
gem 'haml'
gem 'haml-rails'
gem 'kaminari'
gem 'nestful'
gem 'nokogiri', '>= 1.6.8'
gem 'pg'
gem 'puma'
gem 'redcarpet'
gem 'redis-rails', '~> 4.0'
gem 'redis-namespace'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'simple_form'
gem 'susy'

group :production do
  gem 'rails_serve_static_assets'
  gem 'uglifier', '~> 2.7'
  gem 'europeana-logging', '~> 0.1.1'
end

group :development, :test do
  gem 'annotate', '>= 2.6.0'
  gem 'binding_of_caller'
  gem 'dotenv-rails'
  gem 'rails-erd'
  gem 'rspec-rails', '~> 3.4.2', '>= 3.4.2'
  gem 'rubocop', '0.39.0', require: false # only update when Hound does
  gem 'seed_dump'
end

group :development do
  gem 'foreman'
  gem 'rails_best_practices'
  gem 'spring'
end

group :test do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
end

group :doc do
  gem 'yard'
end
