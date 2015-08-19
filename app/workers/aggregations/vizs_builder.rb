class Aggregations::VizsBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Building Vizs", error_messages: nil)
      begin
        aggregation.core_datacasts.each do |core_datacast|
          next if core_datacast.name.include?("Top Digital Objects") or core_datacast.name.include?("Collections")
          genre = core_datacast.name.split(" - ")[1].parameterize("_")
          ref_chart = Aggregations::VizsBuilder.get_ref_chart(genre)
          core_viz = Core::Viz.new({core_datacast_identifier: core_datacast.identifier, name: core_datacast.name, ref_chart_combination_code: ref_chart.combination_code,core_project_id: core_datacast.core_project_id})
          core_viz = Aggregations::VizsBuilder.get_filters(core_viz, genre)
          core_viz.save(validate: false)
        end
        Aggregations::ReportBuilder.perform_async(aggregation_id)
      rescue => e
      end
    end
  end

  def self.get_filters(core_viz, genre)
    if ["reusables","media_types"].include?(genre)
      core_viz.filter_present = false
      core_viz.filter_column_name = nil
      core_viz.filter_column_d_or_m = nil
    else
      core_viz.filter_present = true  
      core_viz.filter_column_name = "aggregation_level_value"
      core_viz.filter_column_d_or_m = "d"
    end
    return core_viz
  end

  def self.get_ref_chart(genre)
    ref_slugs = {"media_types" =>"column","traffic" => "grouped-column","reusables" =>"pie","top_countries" => "one-layer-map"}
    ref_chart = Ref::Chart.find_by(slug: ref_slugs[genre])
    return ref_chart
  end
end    