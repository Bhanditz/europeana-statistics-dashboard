# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.month, 'stats.update') do
  EuropeanaStatisticsDashboard::Application.load_tasks
  Rake::Task['scheduled_jobs:load'].invoke
end
