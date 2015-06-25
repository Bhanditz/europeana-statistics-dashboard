class Core::DatacastsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_core_datacast, only: [:show, :edit, :update, :destroy]

  def index
    @core_datacasts = @core_project.core_datacasts
    @core_db_connections = @core_project.core_db_connections
  end

  def show
  end

  def new
    @core_datacast = Core::Datacast.new
  end

  def edit
    core_db_connection = @core_datacast.core_db_connection
    begin
      connection = PG.connect(dbname: core_db_connection.db_name, 
                                  user: core_db_connection.username, 
                                  password: core_db_connection.password, 
                                  port: core_db_connection.port, 
                                  host: core_db_connection.host)
      @preview_data = Core::DataTransform.twod_array_generate(connection.exec(@core_datacast.query))
      gon.preview_data = @preview_data
    rescue => e
      @preview_data = e.to_s
    end
  end

  def create
    @core_datacast = Core::Datacast.new(core_datacast_params)
    if @core_datacast.save
      # if @core_datacast.params_object.present?
      #   Core::Datacast::QueryOutputUploadWorker.perform_async(@core_datacast.id)
      # end
      redirect_to account_core_project_datacasts_path(@account, @core_project), notice: t('c.s')
    else
      flash.now.alert = t('c.f')
      render "new"
    end
  end

  def update
    if @core_datacast.update(core_datacast_params)
      # if @core_datacast.params_object.present?
      #   Core::Datacast::QueryOutputUploadWorker.perform_async(@core_datacast.id)
      # end
      redirect_to account_core_project_datacasts_path(@account, @core_project), notice: t('u.s')
    else
      flash.now.alert = t('u.f')
      render "edit"
    end 
  end

  def destroy
    @core_datacast.destroy
    redirect_to account_core_project_datacasts_path(@account, @core_project)
  end

  def preview
    respond_to do |format|
      format.json { 
        begin
          response = {}
          query =  params["query"]
          core_db_connection =  @core_project.core_db_connections.find(params["core_db_connection_id"])
          connection = PG.connect(dbname: core_db_connection.db_name, 
                                  user: core_db_connection.username, 
                                  password: core_db_connection.password, 
                                  port: core_db_connection.port, 
                                  host: core_db_connection.host)
          data = connection.exec(query)
          response["query_output"] = Core::DataTransform.twod_array_generate(data)
          response["execute_flag"] = true
          render json: response
        rescue => e
          response["query_output"] = e.to_s
          response["execute_flag"] = false
          render json: response, status: :unprocessable_entity
        end
      }
    end
  end

  private
  
  def set_core_datacast
    @core_datacast = @core_project.core_datacasts.find(params[:id])
  end

  def core_datacast_params
    params.require(:core_datacast).permit(:core_project_id, :core_db_connection_id, :name, :identifier, :properties, :created_by, :updated_by, :query, :method, :refresh_frequency, :caching_method, :error, :fingerprint, :count_of_queries, :last_execution_time, :average_execution_time, :size)
  end
  
end
