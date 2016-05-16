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
end