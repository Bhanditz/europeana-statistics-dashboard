module DatacastsHelper
  
  def signal_datacast_status(d)
    d.error.present? ? "<div class='signal sig-red'></div>".html_safe : d.last_run_at.blank? ? "<div class='signal sig-gray'></div>".html_safe : "<div class='signal sig-green'></div>".html_safe
  end
    
end