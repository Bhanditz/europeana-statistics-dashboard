class Aggregations::ReportBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    if aggregation.genre == "provider" or aggregation.genre == "data_provider"
      aggregation.update_attributes(status: "Building Report", error_messages: nil)
      begin
        core_template = Core::Template.default_provider_template
        variable_object = {}
        core_vizs = aggregation.core_vizs
        required_variables = core_template.required_variables["required_variables"]
        #Putting Wikipedia Content
        wikipedia_content_key = required_variables.shift
        wikipedia_content_value =  aggregation.wikipedia_content
        variable_object[wikipedia_content_key] = wikipedia_content_value
        
        #Putting Collections
        collection_content_key = required_variables.shift
        collection_content_value = ActionController::Base.helpers.number_with_delimiter(aggregation.impl_aggregation_outputs.collections.first.value)
        variable_object[collection_content_key] = collection_content_value
        
        #Putting Media Types
        media_type_content_key = required_variables.shift
        media_type_content_value = core_vizs.media_type.first.auto_html_div
        variable_object[media_type_content_key] = media_type_content_value

        #Putting Reusables
        reusable_content_key = required_variables.shift
        reusable_content_value = core_vizs.reusable.first.auto_html_div
        variable_object[reusable_content_key] = reusable_content_value
        

        #Putting Traffic
        traffic_content_key = required_variables.shift
        traffic_content_value = core_vizs.traffic.first.auto_html_div
        variable_object[traffic_content_key] = traffic_content_value
        

        #Putting Top Countries
        top_countries_content_key = required_variables.shift
        top_countries_content_value = core_vizs.top_country.first.auto_html_div
        variable_object[top_countries_content_key] = top_countries_content_value

        #Putting Top Digital Objects
        top_digital_objects_content_key = required_variables.shift
        top_digital_objects_content_value = aggregation.top_digital_objects_auto_html
        variable_object[top_digital_objects_content_key] = top_digital_objects_content_value


        html_content = core_template.html_content
        variable_object.each do |key, value|
          html_content.gsub!(key, value.to_s)
        end

        a = Impl::Report.create_or_update(aggregation.name, aggregation_id, core_template.id, html_content, variable_object)
        aggregation.update_attributes(status: "Build Report", error_messages: nil)
      rescue => e
        aggregation.update_attributes(status: "Failed to build report", error_messages: e.to_s)
      end
    end
  end
end