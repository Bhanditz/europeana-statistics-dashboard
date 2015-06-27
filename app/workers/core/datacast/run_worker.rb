class Core::Datacast::RunWorker

  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_datacast_id)
    d = Core::Datacast.find(core_datacast_id)
    prev = Core::Datacast.core_datacast_output
    has_fail = false
    begin
      start_time = Time.now
      response = d.run                                                                       # RUN QUERY
      if response["execute_flag"]
        fingerprint = Digest::MD5.hexdigest(response["query_output"])                        # NEW HASH
        time_taken = Time.now - start_time
        if (prev.output.present? and prev.fingerprint != fingerprint) or prev.output.blank?  # IS DATA CHANGE
          d.average_execution_time = ((d.average_execution_time * d.count_of_queries) + time_taken)/d.count_of_queries
          d.last_data_changed_at = Time.now
          d.number_of_rows = response["number_of_rows"]
          d.number_of_columns = response["number_of_columns"]
          d.size = (response["query_output"].bytesize.to_f)/1024
          prev.update_attributes(output: response["query_output"], fingerprint: fingerprint)
          d.error = ""
        end
        #------------------------------------------------------------------------------------- REPEAT QUERY
        #if !core_viz.refresh_freq_in_minutes.nil? and core_viz.refresh_freq_in_minutes > 0
          #ref_min = core_viz.refresh_freq_in_minutes * 60
          #Core::Viz::DatagramWorker.perform_at((Time.now + ref_min), core_viz.id)
        #-------------------------------------------------------------------------------------
      else
        d.error = response["query_output"]
      end
      Core::Datacast::RunWorker.fin(d)
    rescue => e
      d.error = e.to_s
      Core::Datacast::RunWorker.fin(d)
    end
  end
  
  def self.fin(d)
    d.count_of_queries = d.count_of_queries + 1
    d.last_run_at = Time.now
    d.save
  end
  
end