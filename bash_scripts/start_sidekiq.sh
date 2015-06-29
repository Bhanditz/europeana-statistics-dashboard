#! /bin/bash

clear 

echo "-----> Environment = Production"

cd /var/www/html/rumi-io


kill -9 `cat tmp/pids/unicorn.pid`

export RAILS_ENV=production
 
echo "-----> killing All Queues"

kill -9 `cat tmp/pids/sidekiq.pid` `cat tmp/pids/sidekiq0.pid` `cat tmp/pids/sidekiq1.pid`

echo "----> Generating New Queues"

nohup bundle exec sidekiq 0-C config/sidekiq.yml -e production -i 0 &
echo $! > tmp/pids/sidekiq0.pid
nohup bundle exec sidekiq 0-C config/sidekiq.yml -e production -i 1 &
echo $! > tmp/pids/sidekiq1.pid 


sudo service unicorn start

echo "-----> Done"
echo "-----> Press ENTER to continue"