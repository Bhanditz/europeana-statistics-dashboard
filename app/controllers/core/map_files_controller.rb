class Core::MapFilesController < ApplicationController

  before_action :sudo_organisation_owner!, :organisation_counts, except: [:download]
  before_action :set_core_map_file, only: [:show,:update,:destroy,:download]

  def index
    @enable_express_tour = true
    @core_map_file = Core::MapFile.new
    @core_map_files = @account.core_map_files.all
  end

  def show
    gon.file_type = @core_map_file.filetype
  end

  def create
    @core_map_file = Core::MapFile.new(core_map_file_params)
    if params[:core_map_file][:file].present?
      @core_map_file.filetype = params[:core_map_file][:file].original_filename
      @core_map_file.size = (params[:core_map_file][:file].tempfile.size.to_f/1000).round(2)
      @core_map_file.is_public = params[:is_public].present?
      if @core_map_file.save
        Core::MapFile::UploadWorker.perform_async(@core_map_file.id,params[:core_map_file][:file].tempfile.path,params[:core_map_file][:file].original_filename.split(".")[-1])
        redirect_to _account_map_files_path(@account)
      else
        @core_map_files = @account.core_map_files.all
        render :index
      end
    else
      @core_map_files = @account.core_map_files.all
      flash.now.alert = t("mapfile.no_file_added")
      render :index
    end
  end

  def update
    respond_to do |format|
      if @core_map_file.update(core_map_file_params)
        format.json {
          head :ok , notice: t("u.s")
        }
      else
        format.json {
          render json: @core_map_file.errors, status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    if !@core_map_file.is_used
      Core::MapFile::DestroyWorker.perform_async(@core_map_file.id)
      redirect_to _account_map_files_path(@account),notice: t("d.m")
    else
      redirect_to _account_map_files_path(@account),alert: t("map_file.used")
    end
  end

  def download
    account_id = current_account.id if current_account.present?
    Thread.current[:s] = Core::SessionImpl.log_map_file( account_id , request.env["REMOTE_ADDR"].to_s, request.env["HTTP_USER_AGENT"].to_s,@core_map_file.id)
    redirect_to @core_map_file.cdn_published_url
  end

  private
    def set_core_map_file
      @core_map_file = @account.core_map_files.find(params[:id])
    end

    def core_map_file_params
      params.require(:core_map_file).permit(:account_id, :name, :is_public,:file)
    end
end
