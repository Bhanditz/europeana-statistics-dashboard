class Core::Datacast::RunWorker

  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_datacast_id)
    d = Core::Datacast.find(core_datacast_id)
    prev = d.core_datacast_output
    has_fail = false
    begin
      start_time = Time.now
      response = d.run                                                                       # RUN QUERY
      if response["execute_flag"]
        fingerprint = Digest::MD5.hexdigest(response["query_output"])                        # NEW HASH
        time_taken = Time.now - start_time
        if (prev.output.present? and prev.fingerprint != fingerprint) or prev.output.blank?  # IS DATA CHANGE
          d.average_execution_time = d.average_execution_time.blank? ? time_taken : ((d.average_execution_time * d.count_of_queries) + time_taken)/d.count_of_queries
          d.last_data_changed_at   = Time.now
          d.number_of_rows         = response["number_of_rows"]
          d.number_of_columns      = response["number_of_columns"]
          d.size                   = (response["query_output"].bytesize.to_f)/1024
          d.error                  = ""
          prev.update_attributes(output: response["query_output"], fingerprint: fingerprint)
        end
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
    d.count_of_queries = d.count_of_queries.blank? ? 1 : d.count_of_queries + 1
    d.last_run_at = Time.now
    d.save
    #REPEAT QUERY
    if d.refresh_frequency.present? and d.refresh_frequency > 0
      Core::Datacast::RunWorker.perform_at((Time.now + (d.refresh_frequency * 60)), core_datacast_id)
    end
  end
  
end