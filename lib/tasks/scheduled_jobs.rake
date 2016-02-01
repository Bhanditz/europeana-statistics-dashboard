namespace :scheduled_jobs  do
  task :load => :environment do  |t, args|
    Impl::Aggregation.data_providers.each do |d|
      Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
      Impl::DataProviders::DataSetBuilder.perform_async(d.id)
    end

    Impl::Aggregation.providers.each do |d|
      Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
      Impl::DataProviders::DataSetBuilder.perform_async(d.id)
    end

    Impl::Aggregation.countries.each do |d|
      Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
      Impl::DataProviders::DataSetBuilder.perform_async(d.id)
    end


    europeana = Impl::Aggregation.europeana
    Aggregations::Europeana::DatacastBuilder.perform_async
    Impl::DataProviders::MediaTypesBuilder.perform_async(europeana.id)
    Aggregations::Europeana::PageviewsBuilder.perform_async
  end
end