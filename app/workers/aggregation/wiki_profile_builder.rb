class Aggregation::WikiProfileBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "pulling wiki content")
    aggregation_output = Impl::Output.find_or_create(aggregation_id,"Impl::Aggregation","wiki_name")
    begin
      #here wiki data will be fetched and Processed for Reusables
      wiki_url =  URI.encode("https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{aggregation.wikiname}")
      wiki_json = JSON.parse(open(wiki_url).read)
      html_template = ""
      if wiki_context.length > 0
        length = wiki_context.length > 300? 300 : wiki_context.length
        wiki_context = wiki_context[0..length].gsub("\n","").gsub("<p>","").gsub("</p>","")
        html_template += "<div class='row'><div class='col-sm-12'><div id='wiki_name'>#{wiki_context}...<a href='http://en.wikipedia.org/wiki/#{aggregation.wikiname}' target='blank '><b>Read more on Wikipedia</b></a></p></div></div></div>"
      end
      aggregation_output.update_attributes(output: html_template,status: "Processed wiki content")
      aggregation.update_attributes(status: "Processed wiki content")        
    rescue => e
      aggregation_output.update_attributes(status: "Failed", error_messages: e.to_s)
      aggregation.update_attributes(status: "Failed", error_messages: e.to_s)
    end
  end
end