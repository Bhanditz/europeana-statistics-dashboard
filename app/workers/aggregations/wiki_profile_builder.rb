class Aggregations::WikiProfileBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "pulling wiki content")
    begin
      wiki_url =  URI.encode("https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{aggregation.wikiname}")
      wiki_context = JSON.parse(open(wiki_url).read)
      aggregation.wikipedia_content = wiki_context["query"]["pages"].values.first["extract"]
      aggregation.status = "fetched wiki content"        
      aggregation.properties_will_change!
      aggregation.save
    rescue => e
      aggregation.update_attributes(status: "Failed", error_messages: e.to_s)
    end
  end
end