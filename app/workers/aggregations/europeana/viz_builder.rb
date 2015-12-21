class Aggregations::Europeana::VizBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform
    aggregation = Impl::Aggregation.europeana
    if aggregation.genre == "europeana"
      aggregation.update_attributes(status: "Building Vizs", error_messages: nil)
      begin
        aggregation.core_datacasts.each do |core_datacast|
          next if core_datacast.name.include?("Top Digital Objects")
          genre = core_datacast.name.split(" - ").last.parameterize("_")
          puts core_datacast.id
          filter_present, filter_column_name, filter_column_d_or_m = Aggregations::Europeana::VizBuilder.get_filters(genre)
          ref_chart = Aggregations::Europeana::VizBuilder.get_ref_chart(genre)
          validate = false
          core_viz = Core::Viz.find_or_create(core_datacast.identifier,core_datacast.name,ref_chart.combination_code,core_datacast.core_project_id,filter_present,filter_column_name,filter_column_d_or_m, validate,true)
        end
        Aggregations::Europeana::ReportBuilder.perform_async(aggregation_id)
      rescue => e
        aggregation.update_attributes(status: "Failed to build Vizs", error_messages: e.to_s)
      end
    end
  end

  def self.get_filters(genre)
    if ["reusables","providers_count","countries_count",'data_providers_count',"top_countries","media_type_donut_chart","line_chart"].include?(genre)
      filter_present = false
      filter_column_name = nil
      filter_column_d_or_m = nil
    else
      filter_present = true
      filter_column_name = nil
      filter_column_d_or_m = nil
    end
    return filter_present, filter_column_name, filter_column_d_or_m
  end

  def self.get_ref_chart(genre)
    puts genre
    ref_slugs = {"reusables" =>"pie","top_countries" => "one-layer-map", "line_chart" => "multi-series-line","providers_count" => "one-number-indicator","data_providers_count" => "one-number-indicator","countries_count" => "one-number-indicator","media_type_donut_chart" => "election-donut"}
    ref_chart = Ref::Chart.find_by(slug: ref_slugs[genre])
    return ref_chart
  end
end