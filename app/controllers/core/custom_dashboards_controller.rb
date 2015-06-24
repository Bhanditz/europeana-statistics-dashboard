class Core::CustomDashboardsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_core_custom_dashboard, only: [:pull, :destroy]

  def index
    @core_custom_dashboards = @core_project.custom_dashboards.page(params[:page])
    @core_custom_dashboard = Core::CustomDashboard.new
  end

  def create
    @core_custom_dashboard = Core::CustomDashboard.new(core_custom_dashboard_params)
    @core_custom_dashboard.cdn_bucket = "#{Constants::AMAZON_S3_BUCKET}.#{@core_custom_dashboard.name}.#{SecureRandom.hex(18)}".downcase
    begin
      @core_custom_dashboard.ssh_private_key = open(core_custom_dashboard_params[:ssh_private_key]).read if core_custom_dashboard_params[:ssh_private_key].present?
      if @core_custom_dashboard.save
      Core::GitToS3::UploadWorker.perform_async(@core_custom_dashboard.id)
      redirect_to account_core_project_custom_dashboards_path(@core_project.account, @core_project), notice: t("publish")
      else
        @core_custom_dashboards = @core_project.custom_dashboards.page(params[:page])
        flash.now.alert = t("c.f")
        render :index
      end
    rescue => e
      @core_custom_dashboard.errors.add(:ssh_private_key,e.to_s)
      @core_custom_dashboards = @core_project.custom_dashboards.page(params[:page])
      flash.now.alert = t("c.f")
      render :index
    end
  end
  
  def pull
    @core_custom_dashboard.update_attributes(cdn_status: "Preparing.")
    Core::GitToS3::UploadWorker.perform_async(@core_custom_dashboard.id)
    redirect_to account_core_project_custom_dashboards_path(@core_project.account, @core_project), notice: t("publish")
  end

  def destroy
    Core::GitToS3::DestroyWorker.perform_async(@core_custom_dashboard.cdn_bucket)
    @core_custom_dashboard.destroy
    redirect_to account_core_project_custom_dashboards_path(@core_project.account, @core_project), notice: t("d.s")
  end

  private
  
  def set_core_custom_dashboard
    @core_custom_dashboard = @core_project.custom_dashboards.friendly.find(params[:id])
  end

  def core_custom_dashboard_params
    params.require(:core_custom_dashboard).permit(:core_project_id, :name, :properties, :created_by, :updated_by, :git_url, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count, :cdn_status, :ssh_private_key)
  end
  
end
