namespace :scheduled_jobs  do
  task :load => :environment do  |t, args|

    cnt = 0
    Impl::Aggregation.all.each do |d|
      Impl::Country::ProviderBuilder.perform_async(d.id) if d.genre == "country"
      Impl::DataProviders::MediaTypesBuilder.perform_at(cnt.seconds.from_now,d.id)
      Impl::DataProviders::DataSetBuilder.perform_at(cnt.seconds.from_now,d.id)
      cnt += 10
    end

    europeana = Impl::Aggregation.europeana
    Impl::DataProviders::MediaTypesBuilder.perform_async(europeana.id)
    Aggregations::Europeana::PageviewsBuilder.perform_async
    Aggregations::Europeana::DatacastBuilder.perform_async
  end
end