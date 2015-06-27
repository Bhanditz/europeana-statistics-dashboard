class Core::DataStorePullsController < ApplicationController
  before_action :sudo_project_member!, only: [:create,:edit,:update,:destroy]
  before_action :set_data_store_pull, only: [:edit,:update,:destroy]

  def edit
  end

  def create
    @data_store_pull = Core::DataStorePull.new
    url = core_data_store_pull_params[:file_url]
    if url.present? and url != ""
      @data_store_pull.file_url = url
      @data_store_pull.core_project_id = core_data_store_pull_params[:core_project_id]
      @data_store_pull.first_row_header = params[:first_row_header].present? ? true : false
      if @data_store_pull.save
        Core::UploadFromFTP::UploadWorker.perform_async(@data_store_pull.id)
        redirect_to _account_project_path(@core_project.account, @core_project), notice: t("w.s")
      else
        @data_store = Core::DataStore.new
        flash.now.alert = t("c.f")
        render  "core/data_stores/new" 
      end
    else
      @data_store = Core::DataStore.new
      flash.now.alert = t("c.f")
      render "core/data_stores/new"
    end
  end

  def destroy
    @data_store_pull.destroy
    redirect_to _account_project_path(@core_project.account, @core_project), notice: t('d.s')
  end

  def update
    @data_store_pull.file_url = core_data_store_pull_params[:file_url]
    @data_store_pull.first_row_header = params[:first_row_header].present? ? true : false
    if @data_store_pull.save
      Core::UploadFromFTP::UploadWorker.perform_async(@data_store_pull.id)
      redirect_to _account_project_path(@core_project.account, @core_project), notice: t("w.s")
    else
      render :edit
    end

  end

  private
    
  def set_data_store_pull
    @data_store_pull = @core_project.core_data_store_pulls.find(params[:id])
  end

  def core_data_store_pull_params
    params.require(:core_data_store_pull).permit(:core_project_id, :file_url, :first_row_header)
  end
    
end
