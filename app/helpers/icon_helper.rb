module IconHelper
  # Returns a html string for trash button used for deleting an object.
  #
  # @param p [Core::Project] a Core::Project object.
  # @return [String] link to delete link of the project.
  def icon_del(p)
    link_to "<b class='glyphicon glyphicon-trash'></b>".html_safe, p, :method => :delete, data: { confirm: 'Are you sure you want to delete?' }
  end

  # Returns a html string for lock icon.
  def icon_lock
    "<b class='glyphicon glyphicon-lock' style='color: #FFF700;'></b>".html_safe
  end
end