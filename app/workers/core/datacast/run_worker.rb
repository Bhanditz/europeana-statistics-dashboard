class Core::Datacast::RunWorker

  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_datacast_id)
    d = Core::Datacast.find(core_datacast_id)
    prev = d.core_datacast_output
    has_fail = false
    begin
      start_time = Time.now
      response = d.run("raw")                                                                       # RUN QUERY
      if response["execute_flag"]
        query_data = d.format == "2darray" ? Core::DataTransform.twod_array_generate(response["query_output"]) : d.format == "json" ? Core::DataTransform.json_generate(response["query_output"]) : d.format == "xml" ? Core::DataTransform.json_generate(response["query_output"], true) : Core::DataTransform.csv_generate(response["query_output"])
        fingerprint = Digest::MD5.hexdigest(query_data.to_s)                        # NEW HASH
        time_taken = Time.now - start_time
        if (prev.output.present? and prev.fingerprint != fingerprint) or prev.output.blank? or d.column_properties == {} # IS DATA CHANGE
          d.average_execution_time = d.average_execution_time.blank? ? time_taken : ((d.average_execution_time * d.count_of_queries) + time_taken)/d.count_of_queries
          d.last_data_changed_at   = Time.now
          d.number_of_rows         = response["number_of_rows"]
          d.number_of_columns      = response["number_of_columns"]
          d.size                   = query_data.to_s.bytesize.to_f
          d.error                  = ""
          array_data = d.format == "2darray" ? query_data.dup : Core::DataTransform.twod_array_generate(response["query_output"])
          col = {}
          if !array_data.blank? and array_data != "0" and array_data != 0
            column_data_distribution = Core::Datacast.get_data_distribution(array_data)
            column_data_distribution.each do |key, value|
              col_name, col_data_type = key, Core::Datacast.get_col_datatype(value)
              d_or_m = ["integer","double"].include?(col_data_type) ? "m" : "d"
              col[col_name] = {"data_type": col_data_type,"d_or_m": d_or_m, "data_distribution": value}
            end
          end
          prev.update_attributes(output: query_data, fingerprint: fingerprint)
          d.column_properties = col
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
    if d.refresh_frequency.present? and d.refresh_frequency.to_i > 0                                #REPEAT QUERY
      Core::Datacast::RunWorker.perform_at((Time.now + (d.refresh_frequency * 60)), core_datacast_id)
    end
  end
end