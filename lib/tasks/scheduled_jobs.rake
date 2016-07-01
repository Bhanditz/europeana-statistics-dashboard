namespace :scheduled_jobs  do
  task :load => :environment do

    begin
      Mailer.job_status("aashutosh.bhatt@pykih.com", "The Jobs for " +  Time.now.strftime("%B") + " have started.").deliver_now
      Mailer.job_status("ab@pykih.com", "The Jobs for " +  Time.now.strftime("%B") + " have started.").deliver_now
      Mailer.job_status("joris.pekel@europeana.eu", "The Jobs for " +  Time.now.strftime("%B") + " have started.").deliver_now
      Mailer.job_status("mirko.lorenz@gmail.com", "The Jobs for " +  Time.now.strftime("%B") + " have started.").deliver_now
    rescue Exception => e
      cnt = 0
      Impl::Aggregation.where.not(genre: "europeana").all.each do |d|
        Impl::Country::ProviderBuilder.perform_async(d.id) if d.genre == "country"
        Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
        Impl::DataProviders::DataSetBuilder.perform_at(cnt.seconds.from_now,d.id)
        cnt += 10
      end

      europeana = Impl::Aggregation.europeana
      Impl::DataProviders::MediaTypesBuilder.perform_async(europeana.id)
      Aggregations::Europeana::PageviewsBuilder.perform_async
    end
  end
end