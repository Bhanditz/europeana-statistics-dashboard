module ApplicationHelper

  # Returns a gravatar url for a particular email and of a particular size.
  #
  # @param email [String] the email_id of the user, size [Fixnum] size of the image (default 20).
  # @return [String] the url for the image.
  def dp(email, size=20)
    identifier = Digest::MD5.hexdigest((email.blank? ? "" : email).downcase)
    "https://gravatar.com/avatar/#{identifier}.png?s=#{size}"
  end

  # Returns a gravatar url for a particular email and of a particular size.
  #
  # @param a [Object] instance of class Account (User).
  # @return [String] the url for the image.
  def account_image(a, size=20)
    dp(a.gravatar_email_id, size)
  end

  # Returns a html string for a particular project.
  #
  # @param p [Core::Project] a Core::Project object.
  # @return [String] html string that is link to project.
  def show_project_name(p)
    str = "<a class='thin gray' style='letter-spacing: -1px; margin-left: 30px;' href='#{h(_account_project_path(p.account, p))}'>Home</a>"
    return str.html_safe
  end

  # Returns a html string that is a status indicator for a background task. The retrun html string has a particular CSS based on the status.
  #
  # @param impl [Impl::Aggregation] a Impl::Aggregation object.
  # @return [String] html string that has a desired CSS class.
  def get_impl_status(impl)
    (impl.status.downcase.include?("failed") and impl.error_messages.present?)  ? "<div class='signal sig-red'></div>" : (impl.status.downcase.include?("building") or impl.status.downcase.include?("queue"))  ?  "<div class='signal sig-gray'></div>" : "<div class='signal sig-green'></div>"
  end

  # Returns a symbol :account (Devise)
  def resource_name
    :account
  end

  # Returns an instance of Account if user is not present. (Devise)
  def resource
    @resource ||= Account.new
  end

  # Returns Devise mapping for :account if not present. (Devise)
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:account]
  end

  # Returns a html string <time> tag that holds the time in UTC format.
  #
  # @param time [Time] a Time object, options [Object] can have property class to specify the class of the html tag, merge method that stores time in utc format.
  # @return [String] html <time> tag.
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:time, time.to_s, options.merge(datetime: time.getutc.iso8601)) if time
  end

end
