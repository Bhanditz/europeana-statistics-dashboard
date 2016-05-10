class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :set_universal_objects
  before_action :configure_devise_params, if: :devise_controller?
  before_filter :log_session
  after_filter  :after_filter_set
  include ERB::Util

  #------------------------------------------------------------------------------------------------------------------

  private

  def set_universal_objects
    if params[:account_id].present?
      begin
        @account = Account.friendly.find(params[:account_id])
        begin
          if controller_name == "projects" and params[:id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{params[:id]}").first
            raise "no project found" if @core_project.nil?
          elsif params[:project_id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{params[:project_id]}").first
            raise "no project found" if @core_project.nil?
          elsif params[:core_project_id].present?
            @core_project = @account.core_projects.where(account_id: @account.id, slug:"#{params[:core_project_id]}").first
            raise "no project found" if @core_project.nil?
          end
        rescue
          redirect_to root_url, alert: t("set_universal_objects.no_such_project")
        end
      rescue
        redirect_to root_url, alert: t("set_universal_objects.no_such_account_1")
      end
    elsif (controller_name == "accounts" or controller_name == "params") and params[:id].present?
      begin
        @account = Account.friendly.find("#{params[:id]}")
      rescue
        redirect_to root_url, alert: t("set_universal_objects.no_such_account_2")
      end
    end
    if @account.blank?
      @account = current_account  if controller_name == "projects" and action_name == "new"
    end
    gon.scopejs = "scopejs_#{controller_name}_#{action_name}"
    @about_report = Impl::Report.where(slug: "about").first
    @is_beta = true
  end

  #------------------------------------------------------------------------------------------------------------------

  protected

  def log_session
    if current_account.present?
      Core::SessionImpl.log(session.id, current_account.id, request.env["REMOTE_ADDR"].to_s, request.env["HTTP_USER_AGENT"].to_s)
    end
  end

  # Enable DEVISE forms to accept username.
  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:username, :email, :password)}
    devise_parameter_sanitizer.for(:sign_in) {|u| u.permit(:username, :password)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:password, :current_password, :password_confirmation)}
  end

  #------------------------------------------------------------------------------------------------------------------

  private

  def after_sign_in_path_for(resource)
    _account_project_path(resource, resource.core_projects.first)
  end

  def after_filter_set
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

end
