class Core::DatacastsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_core_datacast, only: [:edit, :update, :destroy, :run_worker]
  before_action :set_token,only: [:upload,:destroy]

  def index
    @core_datacasts = @core_project.core_datacasts.includes(:core_db_connection).order(updated_at: :desc)
    @pending_datacast_pulls = @core_project.core_datacast_pulls
  end

  def new
    @core_db_connections = @core_project.core_db_connections + [Core::DbConnection.default_db]
    @core_datacast = Core::Datacast.new
  end

  def file
    @core_db_connections = @core_project.core_db_connections + [Core::DbConnection.default_db]
    @core_datacast = Core::Datacast.new
    @core_datacast_pull = Core::DatacastPull.new
  end

  def edit
    @preview_data = @core_datacast.core_datacast_output
    gon.query_output = @preview_data.output
    if @core_datacast.format == "csv"
      gon.query_output = CSV.parse(@preview_data.output)[0..500] unless @preview_data.output.nil?
    elsif ["2darray","json"].include?(@core_datacast.format)
      gon.query_output = JSON.parse(@preview_data.output)[0..500] unless @preview_data.output.nil?
    end
    gon.format = @core_datacast.format
  end

  def create
    @core_datacast = Core::Datacast.new(core_datacast_params)
    @core_datacast.identifier = SecureRandom.hex(33)
    if @core_datacast.save
      redirect_to _account_project_path(@account, @core_project), notice: t('c.s')
    else
      @core_db_connections = @core_project.core_db_connections + [Core::DbConnection.default_db]
      flash.now.alert = t('c.f')
      render "new"
    end
  end

  def update
    if @core_datacast.update(core_datacast_params)
      Core::Datacast::RunWorker.perform_async(@core_datacast.id)
      redirect_to _account_project_path(@account, @core_project), notice: t('u.s')
    else
      flash.now.alert = t('u.f')
      render "edit"
    end 
  end

  def preview
    respond_to do |format|
      format.json { 
        query =  params["query"] || ""
        format = params["data_format"] == "csv" ? "2darray" : params["data_format"]
        core_db_connection = Core::DbConnection.find(params["core_db_connection_id"])
        response = Core::Adapters::Db.run(core_db_connection, query,format, 500)
        if response['query_output'].blank?
          response["query_output"] = ""
        end
        if response['execute_flag']
          render json: response
        else
          render json: response, status: :unprocessable_entity
        end
      }
    end
  end
  
  def csv
    #s = "/tmp/#{SecureRandom.hex(24)}.csv"
    #@data_store.generate_file_in_tmp(s,@alknfalkfnalkfnadlfkna)
    #send_data IO.read(s), :type => "application/vnd.ms-excel", :filename => "#{@data_store.slug}.csv", :stream => false
    #File.delete(s)
  end
  
  
  def destroy
    begin
      if @core_datacast.table_name.present?
        Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@core_datacast.slug}/grid/delete", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
      end
      @core_datacast.destroy
      redirect_to _account_project_path(@account, @core_project), notice: notice
    rescue => e
      redirect_to _account_project_path(@account, @core_project), alert: e.to_s
    end
  end

  def upload
    if !core_datacast_params[:table_name]
      @core_datacast = Core::DataStore.new
      @datacast_pull = Core::DatacastPull.new
      flash.now.alert = t("datacast.specify_table")
      render :file
    else
      r = Core::Datacast.upload_tmp_file(core_datacast_params[:file])
      if r[1].present?
        alert_message = r[1]
      else
        @core_datacast = Core::Datacast.upload_or_create_file(r[0].file.path, core_datacast_params[:table_name], @core_project.id,core_datacast_params[:core_db_connection_id],core_datacast_params[:table_name],params[:first_row_header] ? true : false, r[2],@alknfalkfnalkfnadlfkna)
      end
      if @core_datacast
        Core::Datacast::RunWorker.perform_async(@core_datacast.id)
        redirect_to _account_project_path(@account, @core_project), notice: t('c.s')
      else
        @core_db_connections = @core_project.core_db_connections + [Core::DbConnection.default_db]
        @core_datacast = Core::Datacast.new
        @core_datacast_pull = Core::DatacastPull.new
        @validator = Csvlint::Validator.new( File.new(r[0].file.path), {"header" => params[:first_row_header], "delimiter" => r[2]} )
        flash.now[:alert] = alert_message || "Failed to upload"
        render :file
      end
    end
  end

  def run_worker
    Core::Datacast::RunWorker.perform_async(@core_datacast.id)
    redirect_to :back, notice: t("datacast.run_worker")
  end

  private
  
  def set_core_datacast
    @core_datacast = @core_project.core_datacasts.friendly.find(params[:id])
  end
  
  def set_token
    @alknfalkfnalkfnadlfkna = @account.core_tokens.where(core_project_id: @core_project.id).first.api_token
    gon.token = @alknfalkfnalkfnadlfkna
  end

  def core_datacast_params
    params.require(:core_datacast).permit(:core_project_id, :core_db_connection_id, :name, :identifier, :properties, :created_by, :updated_by, :query, :method, :refresh_frequency, :error, :fingerprint, :last_execution_time, :average_execution_time, :size,:last_run_at,:last_data_changed_at, :format,:params_object,:column_properties, :table_name, :file)
  end
  
end
