# frozen_string_literal: true
class Impl::DataProviders::DatacastsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # It fetches data for the all the entities (top countries, top digital objects, media types, reusables, pageviews, provider count)
  # for an Impl::Aggregation instance and creates or updates the datacast for each of the entity.
  #
  # @param aggregation_id [Fixnum] id of the instance of Impl:Aggregation.
  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: 'Building Datacasts', error_messages: nil)
    begin
      raise 'Blacklist data set' if aggregation.blacklist_data_set?
    rescue => e
      aggregation.update_attributes(status: 'Failed', error_messages: e.to_s, last_updated_at: nil)
      aggregation.impl_report.delete if aggregation.impl_report
      return nil
    end
    begin

      core_project_id = aggregation.core_project_id
      core_db_connection_id = Core::DbConnection.default_db.id

      unless aggregation.europeana?

        # Top Countries
        top_countries_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Top Countries"
        top_countries_datacast_query = aggregation.get_countries_query
        top_countries_datacast = Core::Datacast.create_or_update_by(top_countries_datacast_query, core_project_id, core_db_connection_id, top_countries_datacast_name)
        Impl::AggregationDatacast.find_or_create(aggregation.id, top_countries_datacast.identifier)

        # Top Digital Objects
        top_digital_objects_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Top Digital Objects"
        top_digital_objects_datacast_query = aggregation.get_digital_objects_query
        top_digital_objects_datacast = Core::Datacast.create_or_update_by(top_digital_objects_datacast_query, core_project_id, core_db_connection_id, top_digital_objects_datacast_name)
        Impl::AggregationDatacast.find_or_create(aggregation.id, top_digital_objects_datacast.identifier)

        # Media Types
        media_type_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Media Type Donut Chart"
        media_type_datacast_query = aggregation.get_static_query('media_type')
        media_type_datacast = Core::Datacast.create_or_update_by(media_type_datacast_query, core_project_id, core_db_connection_id, media_type_datacast_name)
        Impl::AggregationDatacast.find_or_create(aggregation.id, media_type_datacast.identifier)

        # Reusables
        reusable_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Reusables"
        reusable_datacast_query = aggregation.get_static_query('reusable')
        reusable_datacast = Core::Datacast.create_or_update_by(reusable_datacast_query, core_project_id, core_db_connection_id, reusable_datacast_name)
        Impl::AggregationDatacast.find_or_create(aggregation.id, reusable_datacast.identifier)

        # "$Total_PAGEVIEWS$"
        total_pageviews_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Line Chart"
        total_pageviews_datacast_query = aggregation.get_pageviews_line_chart_query
        total_pageviews_datacast = Core::Datacast.create_or_update_by(total_pageviews_datacast_query, core_project_id, core_db_connection_id, total_pageviews_datacast_name)
        Impl::AggregationDatacast.find_or_create(aggregation.id, total_pageviews_datacast.identifier)

        unless aggregation.genre == 'data_provider'
          # Provider Count
          providers_count_datacast_name = "#{aggregation.genre.titleize.upcase} #{aggregation.name} - Providers Count"
          providers_count_datacast_query =  aggregation.get_data_providers_count_query
          providers_count_datacast = Core::Datacast.create_or_update_by(providers_count_datacast_query, core_project_id, core_db_connection_id, providers_count_datacast_name)
          Impl::AggregationDatacast.find_or_create(aggregation.id, providers_count_datacast.identifier)
        end
        Impl::DataProviders::VizsBuilder.perform_async(aggregation_id)
        aggregation.update_attributes(status: 'Created all datacasts')
      end
    rescue => e
      aggregation.update_attributes(status: 'Failed to build datacast', error_messages: e.to_s, last_updated_at: nil)
      aggregation.impl_report.delete if aggregation.impl_report
    end
  end
end
