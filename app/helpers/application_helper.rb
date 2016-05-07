module ApplicationHelper

  def dp(email, size=20)
    identifier = Digest::MD5.hexdigest((email.blank? ? "" : email).downcase)
    "https://gravatar.com/avatar/#{identifier}.png?s=#{size}"
  end

  def account_image(a, size=20)
    dp(a.gravatar_email_id, size)
  end

  def show_project_name(p)
    str = "<a class='thin gray' style='letter-spacing: -1px; margin-left: 30px;' href='#{h(_account_project_path(p.account, p))}'>Home</a>"
    return str.html_safe
  end

  def get_impl_status(impl)
    (impl.status.downcase.include?("failed") and impl.error_messages.present?)  ? "<div class='signal sig-red'></div>" : (impl.status.downcase.include?("building") or impl.status.downcase.include?("queue"))  ?  "<div class='signal sig-gray'></div>" : "<div class='signal sig-green'></div>"
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
