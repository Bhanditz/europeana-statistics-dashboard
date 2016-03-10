class Impl::DataProviders::ReportBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "Building Report", error_messages: nil)
    begin
      variable_object, core_template = Impl::DataProviders::ReportBuilder.get_report_variable_object(aggregation)
      html_content = core_template.html_content
      variable_object.each do |key, value|
        html_content.gsub!(key, value.to_s)
      end

      a = Impl::Report.create_or_update(aggregation.name, aggregation_id, core_template.id, html_content, variable_object, true, aggregation.name.parameterize("-"))
      aggregation.update_attributes(status: "Report built", error_messages: nil)
    rescue => e
      aggregation.update_attributes(status: "Failed to build report", error_messages: e.to_s)
    end
  end

  def self.get_report_variable_object(aggregation)
    case aggregation.genre
    when "data_provider", "provider"
      variable_object, core_template = Impl::DataProviders::ReportBuilder.get_data_provider_object(aggregation)
    when "country"
      variable_object, core_template = Impl::DataProviders::ReportBuilder.get_country_object(aggregation)
    else
      variable_object = {}
    end
    return variable_object,core_template
  end

  def self.get_data_provider_object(aggregation)
    variable_object = {}
    core_template = aggregation.genre == Core::Template.default_europeana_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs
    #["main_chart","topcountries","total_items","open_for_reuse"]
    #Aashutosh change from here

    #"$Total_PAGEVIEWS$"
    line_chart_content_key = required_variables.shift
    line_chart_content_value = core_vizs.line_chart.first.auto_html_div
    variable_object[line_chart_content_key] = line_chart_content_value

    unless aggregation.genre == "data_provider"
      #"$TOTAL_PROVIDERS_COUNT$"
      provider_content_key = required_variables.shift
      providers_content_value = core_vizs.provider_counts.first.auto_html_div
      variable_object[provider_content_key] = providers_content_value
    end

    #"$TOP_DIGITAL_OBJECTS$"
    top_digital_objects_content_key = required_variables.shift
    top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
    variable_object[top_digital_objects_content_key] = top_digital_objects_content_value

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

  def self.get_country_object(aggregation)
    variable_object = {}
    core_template = aggregation.genre == 'data_provider' ? Core::Template.default_data_provider_template : aggregation.genre == "provider" ? Core::Template.default_provider_template : Core::Template.default_country_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs
    #["$COUNTRY_NAME$","$Total_PAGEVIEWS$","$TOTAL_PROVIDERS_COUNT$","$TOP_DIGITAL_OBJECTS$","$MEDIA_TYPES_CHART$","$REUSABLES_CHART$","$TOP_COUNTRIES_TABLE$"]
    #COUNTRY NAME
    country_name_key = required_variables.shift
    country_name_value = aggregation.name.titleize
    variable_object[country_name_key] = country_name_value

    #"$Total_PAGEVIEWS$"
    line_chart_content_key = required_variables.shift
    line_chart_content_value = core_vizs.line_chart.first.auto_html_div
    variable_object[line_chart_content_key] = line_chart_content_value

    #"$TOP_DIGITAL_OBJECTS$"
    top_digital_objects_content_key = required_variables.shift
    top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
    variable_object[top_digital_objects_content_key] = top_digital_objects_content_value

    unless aggregation.genre == "data_provider"
      #"$TOTAL_PROVIDERS_COUNT$"
      provider_content_key = required_variables.shift
      providers_content_value = core_vizs.provider_counts.first.auto_html_div
      variable_object[provider_content_key] = providers_content_value
    end


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