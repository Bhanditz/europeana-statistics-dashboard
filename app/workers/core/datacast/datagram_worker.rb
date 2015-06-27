class Core::Viz::DatagramWorker

  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_viz_id)
    core_viz = Core::Viz.find(core_viz_id)
    if !core_viz.is_static
      new_output = Core::Viz::DatagramWorker.execute_pykquery(core_viz)
      flag = false
      new_output_size = (new_output.bytesize.to_f)/1024
      if new_output_size < 100
        if core_viz.output.blank?
          flag = true
        else
          old_hash = Core::Viz::DatagramWorker.hash_it(core_viz.output)
          new_hash = Core::Viz::DatagramWorker.hash_it(new_output)
          flag = true   if old_hash != new_hash
        end
        if flag
          core_viz.update_attributes(output: new_output, refreshed_at: Time.now)
          if !core_viz.refresh_freq_in_minutes.nil? and core_viz.refresh_freq_in_minutes > 0
            ref_min = core_viz.refresh_freq_in_minutes * 60
            Core::Viz::DatagramWorker.perform_at((Time.now + ref_min), core_viz.id)
          end
        end
      else
        core_viz.update_attributes(was_output_big: true)
      end
    end
  end
  
  def self.execute_pykquery(core_viz)
    data = Nestful.post "#{REST_API_ENDPOINT}/data/#{core_viz.datagram_identifier}/q", account_slug: core_viz.core_project.account.slug,token: core_viz.core_project.core_tokens.first.api_token
    return JSON.parse(data.body)["data"]
  end
  
  def self.hash_it(text)
    digest = Digest::MD5.hexdigest(text)
    return digest
  end
  
end