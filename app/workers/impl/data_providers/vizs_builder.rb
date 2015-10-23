class Impl::DataProviders::VizsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if ["country","provider","data_provider"].include?(aggregation.genre)
      aggregation.update_attributes(status: "Building Vizs", error_messages: nil)
      begin
        aggregation.core_datacasts.each do |core_datacast|
          next if core_datacast.name.include?("Top Digital Objects") or core_datacast.name.include?("Collections")
          genre = core_datacast.name.split(" - ")[1].parameterize("_")
          filter_present, filter_column_name, filter_column_d_or_m = Impl::DataProviders::VizsBuilder.get_filters(genre)
          ref_chart = Impl::DataProviders::VizsBuilder.get_ref_chart(genre)
          validate = false
          core_viz = Core::Viz.find_or_create(core_datacast.identifier,core_datacast.name,ref_chart.combination_code,core_datacast.core_project_id,filter_present,filter_column_name,filter_column_d_or_m, validate,true)
        end
      rescue => e
      end
      Impl::DataProviders::ReportBuilder.perform_async(aggregation_id)
    end
  end

  def self.get_filters(genre)
    if ["reusables","media_types"].include?(genre)
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
    ref_slugs = {"media_types" =>"column","traffic" => "grouped-column","reusables" =>"pie","top_countries" => "one-layer-map", "line_chart" => "multi-series-line"}
    ref_chart = Ref::Chart.find_by(slug: ref_slugs[genre])
    return ref_chart
  end
end    