class Aggregations::Europeana::ReportBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform
    aggregation = Impl::Aggregation.europeana
    aggregation.update_attributes(status: "Building Report", error_messages: nil)
    begin
      variable_object, core_template = Aggregations::Europeana::ReportBuilder.get_report_variable_object(aggregation)
      html_content = core_template.html_content
      variable_object.each do |key, value|
        html_content.gsub!(key, value.to_s)
      end

      a = Impl::Report.create_or_update(aggregation.name, aggregation.id, core_template.id, html_content, variable_object, true,aggregation.name.parameterize("-"))
      aggregation.update_attributes(status: "Report built", error_messages: nil)
    rescue => e
      aggregation.update_attributes(status: "Failed to build report", error_messages: e.to_s)
    end
  end

  def self.get_report_variable_object(aggregation)
    case aggregation.genre
    when "europeana"
      variable_object, core_template = Aggregations::Europeana::ReportBuilder.get_europeana_object(aggregation)
    else
      variable_object, core_template = {},''
    end
    return variable_object,core_template
  end

  def self.get_europeana_object(aggregation)
    variable_object = {}
    core_template = Core::Template.default_europeana_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs
    #"$Total_PAGEVIEWS$", "$TOP_DIGITAL_OBJECTS$", "$TOTAL_COUNTRIES_COUNT$", "$TOTAL_PROVIDERS_COUNT$", "$TOTAL_DATA_PROVIDERS_COUNT$", "$MEDIA_TYPES_CHART$", "$REUSABLES_CHART$", "$TOP_COUNTRIES_TABLE$"
    #"$Total_PAGEVIEWS$"

    #"$Total_PAGEVIEWS$"
    line_chart_content_key = required_variables.shift
    line_chart_content_value = core_vizs.line_chart.first.auto_html_div
    variable_object[line_chart_content_key] = line_chart_content_value

    #"$TOP_DIGITAL_OBJECTS$"
    top_digital_objects_content_key = required_variables.shift
    top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
    variable_object[top_digital_objects_content_key] = top_digital_objects_content_value

    #"$TOTAL_COUNTRIES_COUNT$"
    total_countries_count_content_key = required_variables.shift
    total_countries_count_content_value = core_vizs.countries_count.first.auto_html_div
    variable_object[total_countries_count_content_key] = total_countries_count_content_value


    #"$TOTAL_PROVIDERS_COUNT$"
    total_providers_count_content_key = required_variables.shift
    total_providers_count_content_value = core_vizs.providers_count.first.auto_html_div
    variable_object[total_providers_count_content_key] = total_providers_count_content_value


    #"$TOTAL_DATA_PROVIDERS_COUNT$"
    total_data_providers_count_content_key = required_variables.shift
    total_data_providers_count_content_value = core_vizs.data_providers_count.first.auto_html_div
    variable_object[total_data_providers_count_content_key] = total_data_providers_count_content_value


    #"$MEDIA_TYPES_CHART$"
    media_type_key = required_variables.shift
    media_type_value = core_vizs.media_type_donut_chart.first.auto_html_div
    variable_object[media_type_key] = media_type_value

    #"$REUSABLES_CHART$"
    reusable_content_key = required_variables.shift
    reusable_content_value = core_vizs.reusable.first.auto_html_div
    variable_object[reusable_content_key] = reusable_content_value

    #"$TOP_COUNTRIES_TABLE$"
    top_countries_content_key = required_variables.shift
    top_countries_content_value = core_vizs.top_country.first.auto_html_div
    variable_object[top_countries_content_key] = top_countries_content_value

    return variable_object, core_template
  end
end