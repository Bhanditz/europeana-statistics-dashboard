class Core::DatacastPullsController < ApplicationController
  before_action :sudo_project_member!, only: [:create,:edit,:update,:destroy]
  before_action :set_datacast_pull, only: [:edit,:update,:destroy]

  def edit
  end

  def create
    @core_datacast_pull = Core::DatacastPull.new(core_datacast_pull_params)
    @core_datacast_pull.first_row_header = params[:first_row_header].present? ? true : false
    if @core_datacast_pull.save
      Core::UploadFromFTP::UploadWorker.perform_async(@core_datacast_pull.id)
      redirect_to _account_project_path(@account, @core_project), notice: t("w.s")
    else
      @core_datacast = Core::Datacast.new
      flash.now.alert = t("c.f")
      render  "core/datacasts/file" 
    end
  end

  def destroy
    @core_datacast_pull.destroy
    redirect_to _account_project_path(@account, @core_project), notice: t('d.s')
  end

  def update
    @core_datacast_pull.file_url = core_datacast_pull_params[:file_url]
    @core_datacast_pull.first_row_header = params[:first_row_header].present? ? true : false
    if @core_datacast_pull.save
      Core::UploadFromFTP::UploadWorker.perform_async(@core_datacast_pull.id)
      redirect_to _account_project_path(@account, @core_project), notice: t("w.s")
    else
      render :edit
    end

  end

  private
    
  def set_datacast_pull
    @core_datacast_pull = @core_project.core_datacast_pulls.find(params[:id])
  end

  def core_datacast_pull_params
    params.require(:core_datacast_pull).permit(:core_project_id,:core_db_connection_id ,:file_url, :first_row_header, :table_name)
  end
    
end
