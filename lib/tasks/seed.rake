#rake seed:setup
#rake seed:users

namespace :seed do

  task :setup => :environment do
    puts "----> Migrations"
    if Rails.env.development?
      begin
        Rake::Task['db:drop'].invoke
      rescue
        nil
      end
      begin
        Rake::Task['db:create'].invoke
      rescue
        nil
      end
    end
    Rake::Task['db:migrate'].invoke
    Rake::Task['ref:load'].invoke
  end

  task :users => :environment do
    puts "----> Creating users"
    accounts = [["europeana_user@europeana.eu", "europeana_user"]]
    accounts.each do |a|
      c = Account.new(email: a[0], username: a[1], password: "Europeana123!@#", confirmation_sent_at: Time.now)
      c.save
    end
  end

  task :test_tables => :environment do
    Rake::Task['ref:load'].invoke
    Rake::Task['ref:create_default_db_connection'].invoke
    Rake::Task['ref:create_default_template'].invoke
    puts "----> Copying Aggregation Data"
    ActiveRecord::Base.connection.execute("COPY impl_aggregations FROM '#{Rails.root}/ref/seeds/impl_aggregations.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Blacklist Data"
    ActiveRecord::Base.connection.execute("COPY impl_blacklist_datasets FROM '#{Rails.root}/ref/seeds/blacklist_data_sets.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Datacasts Data"
    ActiveRecord::Base.connection.execute("COPY core_datacasts FROM '#{Rails.root}/ref/seeds/datacasts.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Aggregation DataSet Data"
    ActiveRecord::Base.connection.execute("COPY impl_aggregation_data_sets FROM '#{Rails.root}/ref/seeds/aggregation_data_sets.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Aggregation Datacasts Data"
    ActiveRecord::Base.connection.execute("COPY impl_aggregation_datacasts FROM '#{Rails.root}/ref/seeds/aggregation_datacasts.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Aggregation Relations Data"
    ActiveRecord::Base.connection.execute("COPY impl_aggregation_relations FROM '#{Rails.root}/ref/seeds/aggregation_relations.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying DataSets Data"
    ActiveRecord::Base.connection.execute("COPY impl_datasets FROM '#{Rails.root}/ref/seeds/data_sets.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Outputs Data"
    ActiveRecord::Base.connection.execute("COPY impl_outputs FROM '#{Rails.root}/ref/seeds/outputs.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Time Aggregation Data"
    ActiveRecord::Base.connection.execute("COPY core_time_aggregations FROM '#{Rails.root}/ref/seeds/time_aggregations.csv' WITH DELIMITER ',' CSV HEADER")
    puts "----> Copying Datacast Outputs Data"
    ActiveRecord::Base.connection.execute("COPY core_datacast_outputs FROM '#{Rails.root}/ref/seeds/datacast_outputs.csv' WITH DELIMITER ',' CSV HEADER")
    Rake::Task['ref:seed_europeana_production_reports'].invoke
  end

end