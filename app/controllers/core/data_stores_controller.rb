class Core::DataStoresController < ApplicationController

  before_action :sudo_project_member!, only: [:new, :upload, :update, :destroy, :publish, :map, :merge, :commit_merge]
  before_action :sudo_public!, only: [:index, :show, :index_all, :csv]
  before_action :sudo_account!, only: [:clone]
  before_action :set_data_store, only: [:show, :edit, :update, :destroy, :csv, :map]
  before_action :set_token, only: [:show, :edit, :upload, :destroy,:csv, :map, :merge, :commit_merge]

  #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def index
    redirect_to _account_project_path(@core_project.account, @core_project)
  end

  def show
    if @sudo[1]
      redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store)
    else
      gon.mode = false
      render layout: "data_stores"
    end
  end

  def new
    @data_store = Core::DataStore.new
    @data_store_pull = Core::DataStorePull.new
  end

  def update
    respond_to do |format|
      if @data_store.update(core_data_store_params)
        format.json { head :ok , notice: t("u.s")}
      else
        format.json { render json: @data_store.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    sudo_project_member!(true)
    if @sudo.present? and @sudo[1]
      gon.mode = true
      render layout: "data_stores"
    else
      redirect_to _account_project_data_store_path(@core_project.account, @core_project, @data_store)
    end
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

  def destroy
    is_deletable = @data_store.check_dependent_destroy?
    if is_deletable[:is_deletable]
      begin
        Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/delete", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
        if @data_store.cdn_published_url.present? #PUBLISH TO CDN Functionality
          @data_store.update_attributes(marked_to_be_deleted: "true")
          Core::S3File::DestroyWorker.perform_async("DataStore", @data_store.id)
          notice = t("d.m")
        else
          @data_store.destroy
          notice = t("d.s")
        end
        redirect_to _account_project_path(@core_project.account, @core_project), notice: notice
      rescue => e
        redirect_to _account_project_path(@core_project.account, @core_project), alert: e.to_s
      end
    else
      redirect_to _account_project_path(@core_project.account, @core_project,d: is_deletable[:dependent_to_destroy],d_id: @data_store.id)
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  # OTHER

  def merge
    @data_store = Core::DataStore.new
    @data_stores = @core_project.data_stores.where("join_query IS NULL")
  end

  def commit_merge
    join_config = JSON.parse(params["core_data_store"]["join_query"])
    @data_store = Core::DataStore.new(name: params["core_data_store"]["name"], core_project_id: @core_project.id)
    if @data_store.save
      begin
        response = Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/join", {:token => @alknfalkfnalkfnadlfkna, :join_config => join_config}, :format => :json
        redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: t("c.s")
      rescue
        response = false
      end
    else
      response = false
    end
    if !response
      @data_store = Core::DataStore.new
      @data_store_pull = Core::DataStorePull.new
      flash.now.alert = t("Failed to merge")
      render :new, alert: "Failed to merge"
    end
  end

  def csv
    s = "/tmp/#{SecureRandom.hex(24)}.csv"
    @data_store.generate_file_in_tmp(s,@alknfalkfnalkfnadlfkna)
    send_data IO.read(s), :type => "application/vnd.ms-excel", :filename => "#{@data_store.slug}.csv", :stream => false
    File.delete(s)
  end
  #------------------------------------------------------------------------------------------------------------------

  private

  def set_token
    @alknfalkfnalkfnadlfkna = @account.core_tokens.where(core_project_id: @core_project.id).first.api_token
    gon.token = @alknfalkfnalkfnadlfkna
  end

  def set_data_store
    if params[:data_id].present?
      @data_store = @core_project.data_stores.friendly.find(params[:data_id])
    else
      @data_store = @core_project.data_stores.friendly.find(params[:id])
    end
    @core_projects = current_account.core_projects.where("id <> ?", @data_store.core_project_id)  if current_account.present?
    @parent = @data_store.clone_parent  if @data_store.clone_parent_id.present?
  end

  def core_data_store_params
    params.require(:core_data_store).permit(:core_project_id, :name, :parent_id, :clone_to_core_project_id, :clone_count, :source, :genre, :commit_message, :join_query, :marked_to_be_deleted, :meta_description, :source_url) #hstore - properties
  end

end
