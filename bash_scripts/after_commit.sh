#! /bin/bash

echo "----> Restarting nginx server"

sudo service nginx restart

# # echo "----> Bundle install"

# cd /var/www/html/rumi-io 

# [[ -s "/usr/local/rvm/bin/rvm" ]] && . "/usr/local/rvm/bin/rvm"
# echo "======="
# /usr/local/rvm/gems/ruby-2.1.0@global/bin/bundle install

# RAILS_ENV=production  /usr/local/rvm/gems/ruby-2.1.0@global/bin/bundle rake db:migrate

# # echo "---->  Migrations"

# RAILS_ENV=production rake db:migrate

echo "----> Restarting unicorn server"

sudo service unicorn restart
