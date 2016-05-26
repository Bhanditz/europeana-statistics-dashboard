module DatacastsHelper

  # Returns a html string that is a status indicator for a background task. The retrun html string has a particular CSS based on presence of errors.
  #
  # @param d [Core::Datacast] a Core::Datacast object.
  # @return [String] html <div> string that has a desired CSS class.
  def signal_datacast_status(d)
    d.error.present? ? "<div class='signal sig-red'></div>".html_safe : d.last_run_at.blank? ? "<div class='signal sig-gray'></div>".html_safe : "<div class='signal sig-green'></div>".html_safe
  end

end