# frozen_string_literal: true
namespace :scheduled_jobs do
  task load: :environment do
    begin
      puts 'started scheduled jobs'
    #  Mailer.job_status('aashutosh.bhatt@pykih.com', 'The Jobs for ' + Time.now.strftime('%B') + ' have started.').deliver_now
    #  Mailer.job_status('ab@pykih.com', 'The Jobs for ' + Time.now.strftime('%B') + ' have started.').deliver_now
    #  Mailer.job_status('joris.pekel@europeana.eu', 'The Jobs for ' + Time.now.strftime('%B') + ' have started.').deliver_now
    #  Mailer.job_status('mirko.lorenz@gmail.com', 'The Jobs for ' + Time.now.strftime('%B') + ' have started.').deliver_now
    rescue Exception => e
    end

    cnt = 0
    Impl::Aggregation.where.not(genre: 'europeana').each do |d|
      Impl::Country::ProviderBuilder.perform_async(d.id) if d.genre == 'country'
      Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
      Impl::DataProviders::DataSetBuilder.perform_at(cnt.seconds.from_now, d.id)
      cnt += 10
    end

    europeana = Impl::Aggregation.europeana
    Impl::DataProviders::MediaTypesBuilder.perform_async(europeana.id)
    Aggregations::Europeana::PageviewsBuilder.perform_async
  end

  task create_countries: :environment do
    facet_name = 'COUNTRY'
    all_facets = facets_for facet_name
    all_countries = all_facets.select {|facet_set| facet_set["name"] == facet_name}.first
    all_countries["fields"].each do |facet_field|
      name = facet_field["label"]
      genre = 'country'
      Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
    end
  end

  task create_providers: :environment do
    facet_name = 'PROVIDER'
    all_facets = facets_for facet_name
    all_countries = all_facets.select {|facet_set| facet_set["name"] == facet_name}.first
    all_countries["fields"].each do |facet_field|
      name = facet_field["label"]
      genre = 'provider'
      Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
    end
  end

  task create_data_providers: :environment do
    facet_name = 'DATA_PROVIDER'
    all_facets = facets_for facet_name
    all_countries = all_facets.select {|facet_set| facet_set["name"] == facet_name}.first
    all_countries["fields"].each do |facet_field|
      name = facet_field["label"]
      genre = 'data_provider'
      Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
    end
  end

  task requeue_uncompleted_aggregations: :environment do
    cnt = 0
    limit = ENV['AGGREGATOR_QUEUE_LIMIT'] ||= 1250
    Impl::Aggregation.where.not(genre: 'europeana', status: ['Report built'], error_messages: ['Blacklist data set', 'No data set', 'No media type detected']).limit(limit).each do |d|
      Impl::Country::ProviderBuilder.perform_async(d.id) if d.genre == 'country'
      Impl::DataProviders::MediaTypesBuilder.perform_async(d.id)
      Impl::DataProviders::DataSetBuilder.perform_at(cnt.seconds.from_now, d.id)
      cnt += 10
    end

    europeana = Impl::Aggregation.europeana
    unless europeana.status == 'Report built'
      Impl::DataProviders::MediaTypesBuilder.perform_async(europeana.id)
      Aggregations::Europeana::PageviewsBuilder.perform_async
    end
  end

  def facets_for facet_field
    api_response = JSON.parse(Nestful.get("#{ENV['EUROPEANA_API_URL']}/search.json?wskey=#{ENV['WSKEY']}&query=*:*&rows=0&facet=#{facet_field}&f.#{facet_field}.facet.limit=5000&profile=facets").body)
    api_response["facets"]
  end

  def core_project_id
    core_project_id = Core::Project.where(name: 'Europeana').first.id
  end
end
