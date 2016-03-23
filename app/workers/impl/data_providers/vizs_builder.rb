class Impl::DataProviders::VizsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if ["country","provider","data_provider"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Vizs", error_messages: nil)
      begin
        aggregation.core_datacasts.each do |core_datacast|
          next if core_datacast.name.include?("Top Digital Objects") or core_datacast.name.include?("- Collections") or core_datacast.name.include?("- Search Terms")
          genre = core_datacast.name.split(" - ").last.parameterize("_")
          filter_present, filter_column_name, filter_column_d_or_m = Impl::DataProviders::VizsBuilder.get_filters(genre)
          ref_chart = Impl::DataProviders::VizsBuilder.get_ref_chart(genre)
          validate = false
          core_viz = Core::Viz.find_or_create(core_datacast.identifier,core_datacast.name,ref_chart.combination_code,core_datacast.core_project_id,filter_present,filter_column_name,filter_column_d_or_m, validate,true)
        end
        Impl::DataProviders::ReportBuilder.perform_async(aggregation_id)
      rescue => e
        aggregation.update_attributes(status: "Failed to build Vizs", error_messages: e.to_s)
      end
    end
  end

  def self.get_filters(genre)
    if ["reusables","media_types","item_view","visits","providers_count","top_countries","media_type_donut_chart","item_view_line_chart","working_media_link"].include?(genre)
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
    ref_slugs = {"media_types" =>"column","reusables" =>"pie","top_countries" => "one-layer-map", "line_chart" => "multi-series-line","item_view" => "column","visits" => "one-number-indicator","providers_count" => "one-number-indicator","media_type_donut_chart" => "election-donut","item_view_line_chart" => "multi-series-line","working_media_link" => "one-number-indicator"}
    ref_chart = Ref::Chart.find_by(slug: ref_slugs[genre])
    return ref_chart
  end
end