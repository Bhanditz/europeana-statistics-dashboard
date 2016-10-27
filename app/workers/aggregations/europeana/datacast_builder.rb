# frozen_string_literal: true
class Aggregations::Europeana::DatacastBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # It fetches data for the all the entities (pageviews, digital objects, countries count, provider count, data provider count, media type chart, reusable chart, top countries table)
  # for europeana and creates a datacast for each of the entity.
  def perform
    aggregation = Impl::Aggregation.europeana
    aggregation.update_attributes(status: 'Building Datacasts', error_messages: nil)
    begin

      core_project_id = aggregation.core_project_id

      # "$Total_PAGEVIEWS$"
      total_pageviews_datacast_name = 'Europeana - Line Chart'
      total_pageviews_datacast_query = aggregation.get_pageviews_line_chart_query
      total_pageviews_datacast = Core::Datacast.create_or_update_by(total_pageviews_datacast_query, core_project_id, total_pageviews_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, total_pageviews_datacast.identifier)

      # "$TOP_DIGITAL_OBJECTS$"
      top_digital_objects_datacast_name = 'Europeana - Top Digital Objects'
      top_digital_objects_datacast_query = aggregation.get_digital_objects_query
      top_digital_objects_datacast = Core::Datacast.create_or_update_by(top_digital_objects_datacast_query, core_project_id, top_digital_objects_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, top_digital_objects_datacast.identifier)

      # "$TOTAL_COUNTRIES_COUNT$"
      countries_count_datacast_name = 'Europeana - Countries Count'
      countries_count_datacast_query =  aggregation.get_aggregations_count_query('country')
      countries_count_datacast = Core::Datacast.create_or_update_by(countries_count_datacast_query, core_project_id, countries_count_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, countries_count_datacast.identifier)

      # "$TOTAL_PROVIDERS_COUNT$"
      providers_count_datacast_name = 'Europeana - Providers Count'
      providers_count_datacast_query =  aggregation.get_aggregations_count_query('provider')
      providers_count_datacast = Core::Datacast.create_or_update_by(providers_count_datacast_query, core_project_id, providers_count_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, providers_count_datacast.identifier)

      # "$TOTAL_DATA_PROVIDERS_COUNT$"
      data_providers_count_datacast_name = 'Europeana - Data Providers Count'
      data_providers_count_datacast_query =  aggregation.get_aggregations_count_query('data_provider')
      data_providers_count_datacast = Core::Datacast.create_or_update_by(data_providers_count_datacast_query, core_project_id, data_providers_count_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, data_providers_count_datacast.identifier)

      # "$MEDIA_TYPES_CHART$"
      media_type_datacast_name = 'Europeana - Media Type Donut Chart'
      media_type_datacast_query = aggregation.get_static_query('media_type')
      media_type_datacast = Core::Datacast.create_or_update_by(media_type_datacast_query, core_project_id, media_type_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, media_type_datacast.identifier)

      # "$REUSABLES_CHART$"
      reusable_datacast_name = 'Europeana - Reusables'
      reusable_datacast_query = aggregation.get_static_query('reusable')
      reusable_datacast = Core::Datacast.create_or_update_by(reusable_datacast_query, core_project_id, reusable_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, reusable_datacast.identifier)

      # "$TOP_COUNTRIES_TABLE$"
      top_countries_datacast_name = 'Europeana - Top Countries'
      top_countries_datacast_query = aggregation.get_countries_query
      top_countries_datacast = Core::Datacast.create_or_update_by(top_countries_datacast_query, core_project_id, top_countries_datacast_name)
      Impl::AggregationDatacast.find_or_create(aggregation.id, top_countries_datacast.identifier)

      Aggregations::Europeana::VizBuilder.perform_async
      aggregation.update_attributes(status: 'Created all datacasts')
    rescue => e
      aggregation.update_attributes(status: 'Failed to build datacast', error_messages: e.to_s)
    end
  end
end
