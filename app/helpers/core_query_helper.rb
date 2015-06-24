module CoreQueryHelper
  
  #redis_count("TwitterProcessWorker", )
  def live_count_of_progress(worker)
    redis_key = worker.worker_class.gsub("::", "__")
    if redis_key.index("Api__Process__TwitterWorker")
      $redis.get("#{redis_key}")
    else
      worker.result
    end
  end
  
  def get_custom_style(st)
    if st == "enqueued"
      return "background: #fee08b; color: black;"
    elsif st == "processing"
      return "background: #a6d96a; color: black;"
    elsif st == "failed"
      return "background: #d73027;"
    elsif st == "done"
      return "background: #1a9850;"
    end
  end
  
  def data_store_file_type(gen)
    if gen == "csv"
      "spreadsheet"
    elsif gen == "text"
      "plain-text"
    elsif gen == "json"
      "json"
    end
  end
  
  def data_store_status(obj)
    st = obj.properties["worker_status"]
    if st == "enqueued"
      return "https://s3-ap-southeast-1.amazonaws.com/pykhub/signals/yellow.png"
    elsif st == "processing"
      return "https://s3-ap-southeast-1.amazonaws.com/pykhub/signals/processing.gif"
    elsif st == "failed"
      return "https://s3-ap-southeast-1.amazonaws.com/pykhub/signals/red.png"
    elsif st == "done"
      return "https://s3-ap-southeast-1.amazonaws.com/pykhub/signals/green.png"
    end
  end
  
  def core_worker_status(obj)
    s = obj.status
    "<span class='badge thin' style='#{get_custom_style(s)}'>#{s}</span>".html_safe
  end
    
  def core_worker_time(core_worker)
    st = core_worker.status
    if st == "enqueued"
      "<div class='hint'>#{time_ago_in_words(core_worker.enqueued_at)} ago</div>".html_safe
    elsif st == "processing"
      "<div class='hint'>#{time_ago_in_words(core_worker.start)} ago</div>".html_safe
    elsif (st == "done" or st == "failed") and core_worker.end.present?
      "<div class='hint'>#{time_ago_in_words(core_worker.end)} ago</div>".html_safe
    end
  end
  
end