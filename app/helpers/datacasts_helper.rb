module DatacastsHelper
  
  def signal_datacast_status(d)
    return d.error.present? ? "signal/red.png" : d.last_run_at.blank? ? "signal/yellow.png" : "signal/green.png"
  end
  
end