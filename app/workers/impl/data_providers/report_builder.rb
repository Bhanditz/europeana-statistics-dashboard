class Impl::DataProviders::ReportBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)

    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "Building Report", error_messages: nil)
    begin
      variable_object, core_template = Impl::DataProviders::ReportBuilder.get_report_variable_object(aggregation)
      html_content = ""

      a = Impl::Report.create_or_update(aggregation.name, aggregation_id, core_template.id, html_content, variable_object, true, aggregation.name.parameterize("-"))
      aggregation.update_attributes(status: "Report built", error_messages: nil)
    rescue => e
      aggregation.update_attributes(status: "Failed to build report", error_messages: e.to_s)
    end
  end

  def self.get_report_variable_object(aggregation)
    variable_object = {}
    core_template = Core::Template.default_europeana_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs

    #"$main_chart$"
    line_chart_content_key = required_variables.shift
    line_chart_content_value = core_vizs.line_chart.first.auto_html_json
    line_chart_content_value["title"] = "Monthly page views of items in Europeana."
    line_chart_content_value['description'] = "Total number of visits to items from this collection. Hover over the different months to see exact numbers. You can turn the colour for each year on and off by clicking on it."
    variable_object[line_chart_content_key] = line_chart_content_value

    #"$topcountries$"
    top_countries_content_key = required_variables.shift
    top_countries_content_value = core_vizs.top_country.first.auto_html_json
    top_countries_content_value["title"] = "Top 10 countries. These countries generated the most views in Europeana this year."
    variable_object[top_countries_content_key] = top_countries_content_value

    #"$total_items$"
    media_type_key = required_variables.shift
    media_type_value = core_vizs.media_type_donut_chart.first.auto_html_json
    media_type_value["title"] = "Total number of items in Europeana."
    variable_object[media_type_key] = media_type_value

    #"$open_for_reuse$"
    reusable_content_key = required_variables.shift
    reusable_content_value = core_vizs.reusable.first.auto_html_json
    reusable_content_value["title"] = "How much of the collection is available for re-use?"
    reusable_content_value["description"] = "Every item you find in Europeana comes with a <a href='http://pro.europeana.eu/page/available-rights-statements target='_blank''>rights statements</a> telling you how you can use it. To make it easier, we have divided these rights statements <a href='http://pro.europeana.eu/blogpost/new-features-for-europeana' target='_blank'>into three categories</a>.".html_safe
    variable_object[reusable_content_key] = reusable_content_value

    return variable_object, core_template
  end
end