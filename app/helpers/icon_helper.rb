module IconHelper
  
  def icon_del(p)
    link_to "<b class='glyphicon glyphicon-trash'></b>".html_safe, p, :method => :delete, data: { confirm: 'Are you sure you want to delete?' }
  end
  
  def online
    "<b class='octicon octicon-primitive-dot' style='color: green;'></b> &nbsp;".html_safe
  end
  
  def offline
    "<b class='octicon octicon-primitive-dot' style='color: gray;'></b> &nbsp;".html_safe
  end
  
  def publish
    "<b class='octicon octicon-link'></b> &nbsp;".html_safe
  end
  
  def plot
    "<b class='octicon octicon-graph'></b> &nbsp;".html_safe
  end
  
  def clone
    "<b class='octicon octicon-repo-clone'></b> &nbsp;".html_safe
  end
  
  def icon_lock
    "<b class='glyphicon glyphicon-lock' style='color: #FFF700;'></b>".html_safe
  end
  
  def icon_download
    "<b class='glyphicon glyphicon-download-alt'></b>".html_safe
  end
  
  def folder_open(str)
    "<b class='glyphicon glyphicon-folder-open'></b> #{str}"
  end
  
  def folder_close(str)
    "<b class='glyphicon glyphicon-folder-close'></b> #{str}"
  end
  
  def icon_settings
    "<i class='glyphicon glyphicon-cog'></i>".html_safe
  end
  
  def icon_signout
    "<b class='glyphicon glyphicon-off'></b>".html_safe
  end
  
  def icon_admin
    "<b class='glyphicon glyphicon-flag' style='color: #FFF700;'></b>".html_safe
  end
  def icon_approve
    "<b class='glyphicon glyphicon-thumbs-up'></b>".html_safe
  end
  def icon_disapprove
    "<b class='glyphicon glyphicon-thumbs-down'></b>".html_safe
  end
end