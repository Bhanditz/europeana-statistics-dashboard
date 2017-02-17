# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'stats.update', at: '03:30') do
  # This is only ran on the first day of the month
  if Date.today == Date.today.at_beginning_of_month
    Europeana::StatisticsDashboard::Application.load_tasks
    Rake::Task['scheduled_jobs:load'].invoke
  end
  # For each of the 2 days after the initial monthly enqueuing,
  # we're going to re-try generating any non completed aggregation reports.
  if ((Date.today == (Date.today.at_beginning_of_month + 1.day)) || (Date.today == (Date.today.at_beginning_of_month + 2.days)))
    # Europeana::StatisticsDashboard::Application.load_tasks
    # Rake::Task['scheduled_jobs:requeue_uncompleted_aggregations'].invoke
  end
end
