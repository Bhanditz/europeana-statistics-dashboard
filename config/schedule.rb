set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}
every '0 0 1 * *' do
  rake "scheduled_jobs:load"
end