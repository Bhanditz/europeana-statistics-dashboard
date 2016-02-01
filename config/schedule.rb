every '0 0 1 * *' do
  rake "scheuled_jobs:load"
end