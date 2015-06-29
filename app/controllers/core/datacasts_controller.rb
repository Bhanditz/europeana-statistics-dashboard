class Core::DatacastsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_core_datacast, only: [:edit, :update, :destroy]

  def index
    @core_datacasts = @core_project.core_datacasts.includes(:core_db_connection)
  end

  def new
    @core_db_connections = @core_project.core_db_connections + [Core::DbConnection.default_db]
    @core_datacast = Core::Datacast.new
  end

  def edit
    @preview_data = Core::Adapters::Db.run(@core_datacast.core_db_connection, @core_datacast.query,"2darray", 500)
    gon.query_output = @preview_data["query_output"]
  end

  def create
    @core_datacast = Core::Datacast.new(core_datacast_params)
    @core_datacast.identifier = SecureRandom.hex(33)
    if @core_datacast.save
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
        query =  params["query"] || ""
        core_db_connection = Core::DbConnection.find(params["core_db_connection_id"])
        response = Core::Adapters::Db.run(core_db_connection, query,"2darray", 500)
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
    #is_deletable = @data_store.check_dependent_destroy?
    #if is_deletable[:is_deletable]
      #begin
        #Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/delete", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
        #if @data_store.cdn_published_url.present? #PUBLISH TO CDN Functionality
          #@data_store.update_attributes(marked_to_be_deleted: "true")
          #Core::S3File::DestroyWorker.perform_async("DataStore", @data_store.id)
          #notice = t("d.m")
        #else
          #@data_store.destroy
          #notice = t("d.s")
        #end
        #redirect_to _account_project_path(@core_project.account, @core_project), notice: notice
      #rescue => e
        #redirect_to _account_project_path(@core_project.account, @core_project), alert: e.to_s
      #end
    #else
      #redirect_to _account_project_path(@core_project.account, @core_project,d: is_deletable[:dependent_to_destroy],d_id: @data_store.id)
      #end
  end

  private
  
  def set_core_datacast
    @core_datacast = @core_project.core_datacasts.find(params[:id])
  end

  def core_datacast_params
    params.require(:core_datacast).permit(:core_project_id, :core_db_connection_id, :name, :identifier, :properties, :created_by, :updated_by, :query, :method, :refresh_frequency, :error, :fingerprint, :last_execution_time, :average_execution_time, :size,:last_run_at,:last_data_changed_at, :format,:params_object,:column_properties)
  end
  
end
