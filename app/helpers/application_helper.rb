module ApplicationHelper
  
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def dp(email, size=20)
    identifier = Digest::MD5.hexdigest((email.blank? ? "" : email).downcase)
    "https://gravatar.com/avatar/#{identifier}.png?s=#{size}"
  end
  
  def account_image(a, size=20)
    dp(a.gravatar_email_id, size)
  end
  
  def smart_date(i)
    if i.blank?
      return ""
    elsif i.year == Time.now.year and (i.to_date - Date.today).round == 0
      return i.strftime("%H:%M")
    elsif i.year == Time.now.year
      return i.strftime("%d-%b")
    else
      return i.strftime("%d-%b-%Y")
    end
  end
  
  def show_project_name(p)
    if 1 == 2
      if !p.is_public
        str = "<b class='glyphicon glyphicon-lock' style='color: #FFF700; margin-left: 30px;'></b> "
      else
        str = "<b style='margin-left: 30px;'></b> "
      end
      str = str + "<a class='thin gray' style='letter-spacing: -1px;' href='#{_account_path(p.account)}'>#{p.account.username}</a> <span class='thin'> /</span> <u><a style='letter-spacing: -1px;' href='#{_account_project_path(p.account, p)}'>#{p.name}</a></u>"
    end
    str = "<a class='thin gray' style='letter-spacing: -1px; margin-left: 30px;' href='#{_account_project_path(p.account, p)}'>Home</a>"
    return str.html_safe
  end
  
  def smart_round(num, round_by)
    begin
      num.round(round_by)
    rescue  Exception => e
      return nil
    end
  end

  def get_impl_status(impl)
    impl.error_messages.present?  ? "<div class='signal sig-red'></div>" : impl.status.downcase.include?("building") ?  "<div class='signal sig-gray'></div>" : "<div class='signal sig-green'></div>"
  end
  
  def resource_name
    :account
  end
 
  def resource
    @resource ||= Account.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:account]
  end
  
end
