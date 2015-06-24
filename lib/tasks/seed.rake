#rake seed:setup
#rake seed:users

namespace :seed do

  task :setup => :environment do  |t, args|
    puts "----> Migrations"
    if Rails.env.development?
      begin
        Rake::Task['db:drop'].invoke
      rescue
      end
      begin
        Rake::Task['db:create'].invoke
      rescue
      end
    end
    Rake::Task['db:migrate'].invoke
    Rake::Task['ref:load'].invoke
  end
  
  task :users => :environment do |t, args|
    puts "----> Creating users"
    accounts = [["ritvvij.parrikh@pykih.com", "ritvvijparrikh"], ["ab@pykih.com", "amitbadheka"], ["girish.kulkarni@pykih.com", "girishkulkarni"], ["dr@pykih.com", "darpanrawat"], ["ritvij.j@gmail.com", "ritvij.j"]]
    accounts.each do |a|
      c = Account.new(email: a[0], username: a[1], password: "indianmonsoon123801", accountable_type: Constants::ACC_U, confirmation_sent_at: Time.now)
      c.skip_confirmation!
      c.save
    end
  end

end