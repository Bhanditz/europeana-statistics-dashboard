class Core::DbConnectionsController < ApplicationController
  
  before_action :sudo_project_member!  
  before_action :set_core_db_connection, only: [:edit, :update, :destroy, :refresh, :show]

  def index
    @core_db_connections = @core_project.core_db_connections
    @core_db_connection = Core::DbConnection.new
  end
  
  def show
  end
  
  def edit
    @core_db_connections = @core_project.core_db_connections
    render "index"
  end

  def create
    @core_db_connection = Core::DbConnection.new(core_db_connection_params)
    if @core_db_connection.save
      Core::DbConnections::SyncWorker.perform_async(@core_db_connection.id)
      redirect_to account_core_project_db_connections_path(@account,@core_project)
    else
      @core_db_connections = @core_project.core_db_connections
      render "index"
    end
  end

  def update
    if @core_db_connection.update(core_db_connection_params)
      redirect_to account_core_project_db_connections_path(@account,@core_project)
    else
      @core_db_connections = @core_project.core_db_connections
      render "index"
    end
  end

  def destroy
    @core_db_connection.destroy
    redirect_to account_core_project_db_connections_path(@account, @core_project)
  end

  private

  def set_core_db_connection
    @core_db_connection = Core::DbConnection.find("#{h params[:id]}")
  end

  def core_db_connection_params
    params.require(:core_db_connection).permit(:core_project_id, :name, :adapter, :properties, :host, :port, :username, :password, :db_name)
  end
end
