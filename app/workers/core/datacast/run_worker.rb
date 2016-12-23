# frozen_string_literal: true
class Core::Datacast::RunWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  # Runs the query associated with each datacast. It stores the result of the query in the database.
  #
  # @param core_datacast_id [Fixnum] id of an instance of Core::Datacast.
  def perform(core_datacast_id)
    d = Core::Datacast.find(core_datacast_id)
    prev = d.core_datacast_output
    d.error = ''
    begin
      start_time = Time.now
      response = d.run('raw') # RUN QUERY
      if response['execute_flag']
        query_data = d.format == '2darray' ? Core::DataTransform.twod_array_generate(response['query_output']) : d.format == 'json' ? Core::DataTransform.json_generate(response['query_output']) : d.format == 'xml' ? Core::DataTransform.json_generate(response['query_output'], true) : Core::DataTransform.csv_generate(response['query_output'])
        fingerprint = Digest::MD5.hexdigest(query_data.to_s) # NEW HASH
        time_taken = Time.now - start_time
        if (prev.output.present? && prev.fingerprint != fingerprint) || prev.output.blank? || d.column_properties == {} # IS DATA CHANGE
          d.average_execution_time = d.average_execution_time.blank? ? time_taken : ((d.average_execution_time * d.count_of_queries) + time_taken) / d.count_of_queries
          d.last_data_changed_at   = Time.now
          d.number_of_rows         = response['number_of_rows']
          d.number_of_columns      = response['number_of_columns']
          d.size                   = query_data.to_s.bytesize.to_f
          d.error                  = ''
          array_data = d.format == '2darray' ? query_data.dup : Core::DataTransform.twod_array_generate(response['query_output'])
          col = {}
          prev_col = d.column_properties
          if !array_data.blank? && array_data != '0' && array_data != 0
            column_data_distribution = Core::Datacast.get_data_distribution(array_data)
            column_data_distribution.each do |key, value|
              col_name = key
              col_data_type = Core::Datacast.get_col_datatype(value)
              d_or_m = (prev_col[col_name].present? && !prev_col[col_name]['d_or_m'].nil?) ? prev_col[col_name]['d_or_m'] : %w(integer double).include?(col_data_type) ? 'm' : 'd'
              col[col_name] = { data_type: col_data_type, d_or_m: d_or_m, data_distribution: value }
            end
          end
          prev.update_attributes(output: query_data, fingerprint: fingerprint)
          d.column_properties = col
          d.column_properties_will_change!
        end
      else
        d.error = response['query_output']
      end
      Core::Datacast::RunWorker.fin(d)
    rescue StandardError => e
      d.error = e.to_s
      Core::Datacast::RunWorker.fin(d)
    end
  end

  # It saves the processing done by the RunWorker after updating certain properties, into the database.
  #
  # @param d [Object] instance of Core::Datacast
  def self.fin(d)
    d.count_of_queries = d.count_of_queries.blank? ? 1 : d.count_of_queries + 1
    d.last_run_at = Time.now
    d.save
    if d.refresh_frequency.present? && d.refresh_frequency.to_i > 0 # REPEAT QUERY
      Core::Datacast::RunWorker.perform_at((Time.now + (d.refresh_frequency * 60)), core_datacast_id)
    end
  end
end
