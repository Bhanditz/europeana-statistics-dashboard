class Impl::DataProviders::DatacastsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true
  
  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "Building Datacasts", error_messages: nil)
    begin
      core_project_id = aggregation.core_project_id
      core_db_connection_id = Core::DbConnection.default_db.id

      # Collections in Europeana
      collections_datacast_name = "#{aggregation.name} - Collections"
      collections_datacast_query = aggregation.get_collections_query
      collections_datacast = Core::Datacast.create_or_update_by(collections_datacast_query,core_project_id,core_db_connection_id,collections_datacast_name)
      aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,collections_datacast.identifier)

      unless aggregation.europeana?
        # Media Types
        media_type_datacast_name = "#{aggregation.name} - Media Types"
        media_type_datacast_query = aggregation.get_static_query("media_type")
        media_type_datacast = Core::Datacast.create_or_update_by(media_type_datacast_query,core_project_id,core_db_connection_id,media_type_datacast_name)
        aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,media_type_datacast.identifier)

        # Reusables
        reusable_datacast_name = "#{aggregation.name} - Reusables"
        reusable_datacast_query = aggregation.get_static_query("reusable")
        reusable_datacast = Core::Datacast.create_or_update_by(reusable_datacast_query,core_project_id,core_db_connection_id,reusable_datacast_name)
        aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,reusable_datacast.identifier)


        # Traffic
        traffic_datacast_name = "#{aggregation.name} - Traffic"
        traffic_datacast_query = aggregation.get_traffic_query
        traffic_datacast = Core::Datacast.create_or_update_by(traffic_datacast_query,core_project_id,core_db_connection_id,traffic_datacast_name)
        traffic_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,traffic_datacast.identifier)

        # Top Countries
        top_countries_datacast_name = "#{aggregation.name} - Top Countries"
        top_countries_datacast_query = aggregation.get_countries_query
        top_countries_datacast = Core::Datacast.create_or_update_by(top_countries_datacast_query,core_project_id,core_db_connection_id,top_countries_datacast_name)
        top_countries_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,top_countries_datacast.identifier)

        # Top Digital Objects
        top_digital_objects_datacast_name = "#{aggregation.name} - Top Digital Objects"
        top_digital_objects_datacast_query = aggregation.get_digital_objects_query
        top_digital_objects_datacast = Core::Datacast.create_or_update_by(top_digital_objects_datacast_query,core_project_id,core_db_connection_id,top_digital_objects_datacast_name)
        top_digital_objects_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,top_digital_objects_datacast.identifier)
        aggregation.update_attributes(status: "Created all datacasts")

        # Line Chart
        pageviews_line_chart_datacast_name = "#{aggregation.name} - Line Chart"
        pageviews_line_chart_datacast_query =  aggregation.get_pageviews_line_chart_query
        pageviews_line_chart_datacast = Core::Datacast.create_or_update_by(pageviews_line_chart_datacast_query,core_project_id, core_db_connection_id,pageviews_line_chart_datacast_name)
        pageviews_line_chart_aggregation_datacast = Impl::AggregationDatacast.find_or_create(aggregation.id,pageviews_line_chart_datacast.identifier)

        Aggregations::VizsBuilder.perform_async(aggregation_id)
      end
    rescue => e
      aggregation.update_attributes(status: "Failed to build datacast", error_messages: e.to_s)
    end
  end
end