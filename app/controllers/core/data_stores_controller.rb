class Core::DataStoresController < ApplicationController

  before_action :sudo_project_member!, only: [:new, :upload, :update, :destroy]
  before_action :sudo_public!, only: [:index, :show, :index_all]
  before_action :set_token, only: [:show, :destroy]
 #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def new
    @data_store = Core::DataStore.new
    @data_store_pull = Core::DataStorePull.new
  end

  def upload
    if !params[:core_data_store]
      @data_store = Core::DataStore.new
      @data_store_pull = Core::DataStorePull.new
      flash.now.alert("Please upload file.")
      render :new
    else
      r = Core::DataStore.upload_tmp_file(params[:core_data_store][:file])
      if r[1].present?
        alert_message = r[1]
      else
        @data_store = Core::DataStore.upload_or_create_file(r[0].file.path, r[0].filename, @core_project.id, params[:first_row_header] ? true : false, r[2], @alknfalkfnalkfnadlfkna)
      end
      if @data_store
        begin
          Nestful.get REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/analyse_datatypes", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
        rescue
        end
        redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: t("c.s")
      else
        @validator = Csvlint::Validator.new( File.new(r[0].file.path), {"header" => params[:first_row_header], "delimiter" => r[2]} )
        @data_store = Core::DataStore.new
        @data_store_pull = Core::DataStorePull.new
        flash.now[:alert] = alert_message || "Failed to upload"
        render :new
      end
    end
  end
  #------------------------------------------------------------------------------------------------------------------

  private

  def set_token
    @alknfalkfnalkfnadlfkna = @account.core_tokens.where(core_project_id: @core_project.id).first.api_token
    gon.token = @alknfalkfnalkfnadlfkna
  end

  def set_data_store
    @core_projects = current_account.core_projects.where("id <> ?", @data_store.core_project_id)  if current_account.present?
    @parent = @data_store.clone_parent  if @data_store.clone_parent_id.present?
  end

  def core_data_store_params
    params.require(:core_data_store).permit(:core_project_id, :name, :table_name, :account_id, :db_connection_id)
  end

end
