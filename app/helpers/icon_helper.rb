module IconHelper

  def icon_del(p)
    link_to "<b class='glyphicon glyphicon-trash'></b>".html_safe, p, :method => :delete, data: { confirm: 'Are you sure you want to delete?' }
  end

  def clone
    "<b class='octicon octicon-repo-clone'></b> &nbsp;".html_safe
  end

  def icon_lock
    "<b class='glyphicon glyphicon-lock' style='color: #FFF700;'></b>".html_safe
  end
end