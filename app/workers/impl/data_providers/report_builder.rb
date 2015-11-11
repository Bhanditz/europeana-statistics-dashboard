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

      a = Impl::Report.create_or_update(aggregation.name, aggregation_id, core_template.id, html_content, variable_object, true)
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
    core_template = aggregation.genre == "data_provider" ? Core::Template.default_data_provider_template : Core::Template.default_provider_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs

    #'$DATA_PROVIDER_NAME$','$WIKIPEDIA_LINK$','$MEDIA_TYPE_DONUT_CHART$','$ITEM_VIEWS_LINE_CHART$','$TOP_DIGITAL_OBJECTS$','$TOP_COUNTRIES_TABLE$'
    #Data Provider Name
    data_provider_name_key = required_variables.shift
    data_provider_name_value = aggregation.name.titleize
    variable_object[data_provider_name_key] = data_provider_name_value

    #WIKIPEDIA LINK
    wikipedia_content_key = required_variables.shift
    wikipedia_content_value = aggregation.wikiname.present? ? "<a href='https://en.wikipedia.org/wiki/#{aggregation.wikiname}'>See more on wikipedia.</a>" : ""
    variable_object[wikipedia_content_key] = wikipedia_content_value

    #MEDIA_TYPE_DONUT_CHART
    media_type_key = required_variables.shift
    media_type_value = core_vizs.media_type_donut_chart.first.auto_html_div
    variable_object[media_type_key] = media_type_value

    #ITEM_VIEWS_LINE_CHART
    item_view_key = required_variables.shift
    item_view_value = core_vizs.item_view_line_chart.first.auto_html_div
    variable_object[item_view_key] = item_view_value

    #Putting Top Digital Objects
    top_digital_objects_content_key = required_variables.shift
    top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
    variable_object[top_digital_objects_content_key] = top_digital_objects_content_value

    # #PERCENTAGE_OF_WORKING_MEDIA_LINKS
    # percentage_of_working_media_links_content_key = required_variables.shift
    # percentage_of_working_media_links_content_value = core_vizs.percentage_of_working_media_links.first.auto_html_div
    # variable_object[percentage_of_working_media_links_content_key] = percentage_of_working_media_links_content_value

    #Putting Top Countries
    top_countries_content_key = required_variables.shift
    top_countries_content_value = core_vizs.top_country.first.auto_html_div
    variable_object[top_countries_content_key] = top_countries_content_value

    return variable_object, core_template
  end

  def self.get_country_object(aggregation)
    variable_object = {}
    core_template = Core::Template.default_country_template
    required_variables = core_template.required_variables['required_variables']
    core_vizs = aggregation.core_vizs
    #["$COUNTRY_NAME$", "$MEDIA_TYPES_CHART$", "$ITEM_VIEWS_CHART$", "$TOP_DIGITAL_OBJECTS$", "$TOP SEARCH TERMS$", "$COLLECTIONS_PER_COUNTRY$", "$Total_VISITS$", "$Total_PAGEVIEWS$", "$REUSABLES_CHART$", "$TOP_COUNTRIES_MAP$", "$TOTAL_PROVIDERS_COUNT$"]
    #COUNTRY NAME
    country_name_key = required_variables.shift
    country_name_value = aggregation.name.titleize
    variable_object[country_name_key] = country_name_value

    #MEDIA TYPES
    media_type_key = required_variables.shift
    media_type_value = core_vizs.media_type_donut_chart.first.auto_html_div
    variable_object[media_type_key] = media_type_value

    #ITEM VIEWS
    item_view_key = required_variables.shift
    item_view_value = core_vizs.item_view.first.auto_html_div
    variable_object[item_view_key] = item_view_value

    #Putting Top Digital Objects
    top_digital_objects_content_key = required_variables.shift
    top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
    variable_object[top_digital_objects_content_key] = top_digital_objects_content_value

    #Putting Top Search Terms
    top_search_terms_key = required_variables.shift
    top_search_terms_value = aggregation.top_search_terms_auto_html
    variable_object[top_search_terms_key] = top_search_terms_value

    #Total Visits
    total_visits_key = required_variables.shift
    total_visits_value = core_vizs.total_visits.first.auto_html_div
    variable_object[total_visits_key] = total_visits_value

    #Putting Line Chart
    line_chart_content_key = required_variables.shift
    line_chart_content_value = core_vizs.line_chart.first.auto_html_div
    variable_object[line_chart_content_key] = line_chart_content_value

    #Putting Reusables
    reusable_content_key = required_variables.shift
    reusable_content_value = core_vizs.reusable.first.auto_html_div
    variable_object[reusable_content_key] = reusable_content_value


    #Putting Providers count
    provider_content_key = required_variables.shift
    providers_content_value = core_vizs.provider_counts.first.auto_html_div
    variable_object[provider_content_key] = providers_content_value

    #Putting Top Countries
    top_countries_content_key = required_variables.shift
    top_countries_content_value = core_vizs.top_country.first.auto_html_div
    variable_object[top_countries_content_key] = top_countries_content_value

    return variable_object, core_template
  end
end