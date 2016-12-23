# frozen_string_literal: true
class Impl::DataProviders::MediaTypesBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Fetches the media types data using Europeana API, for a particular provider and stores it in the database.
  #
  # @param aggregation_id [Fixnum] id of the instance of Impl:Aggregation.
  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: 'Building Media Types', error_messages: nil)
    begin
      europeana_query = aggregation.europeana? ? '*:*' : CGI.escape("#{aggregation.genre.upcase}:\"#{aggregation.name}\"")
      media_types = Nestful.get("#{ENV['EUROPEANA_API_URL']}/search.json?wskey=#{ENV['WSKEY']}&query=#{europeana_query}&facet=TYPE&profile=facets&rows=0")
      if media_types['facets'].present? && media_types['facets'].first.present? && media_types['facets'].first['fields'].present?
        media_type_data = media_types['facets'].first['fields'].map { |a| { 'month' => Date.today.month, 'year' => Date.today.year, 'media_type' => a['label'], 'value' => a['count'].to_i } }
        Core::TimeAggregation.create_aggregations(media_type_data, 'monthly', aggregation_id, 'Impl::Aggregation', 'value', 'media_type')
        aggregation.update_attributes(status: 'Processed Media Types')
      else
        raise 'No media type detected'
      end
      Impl::DataProviders::ReusableBuilder.perform_async(aggregation_id)
    rescue => e
      aggregation.update_attributes(status: 'Failed to build media types', error_messages: e.to_s)
    end
  end
end
