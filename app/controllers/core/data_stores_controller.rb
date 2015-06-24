class Core::DataStoresController < ApplicationController

  before_action :sudo_project_member!, only: [:new, :upload, :update, :destroy, :publish, :empty_grid, :map,:mark_as_dictionary,:mark_as_dataset, :append_rows, :commit_append, :merge, :commit_merge]
  before_action :sudo_public!, only: [:index, :show, :index_all, :csv,:open_data]
  before_action :sudo_account!, only: [:clone]
  before_action :set_data_store, only: [:show, :edit, :update, :destroy, :csv, :publish, :clone, :map,:mark_as_dictionary,:mark_as_dataset, :append_rows, :commit_append, :recalibrate_metadata, :assign_metadata, :update_assign_metadata]
  before_action :set_token, only: [:show, :edit, :upload, :destroy, :clone, :empty_grid,:csv,:publish, :map, :merge, :commit_merge, :commit_append, :recalibrate_metadata]

  #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def index
    redirect_to _account_project_path(@core_project.account, @core_project)
  end

  def empty_grid
    @data_store = Core::DataStore.new(name: "Untitled Grid #{rand(100).to_s}", core_project_id: @core_project.id)
    if @data_store.save
      grid_data = [["Alphabet Name", "Column1", "Column2", "Column3", "Column4"], ['Alpha','','','',''], ['Beta','','','',''], ['Gamma','','','',''], ['Delta','','','',''],
                    ['Epsilon','','','',''], ['Zeta','','','',''], ['Eta','','','',''], ['Theta','','','',''], ['Iota','','','','']]
      if Core::DataStore.create_grid(@core_project.slug, @core_project.account.slug, @data_store.slug, @alknfalkfnalkfnadlfkna, grid_data, true)
        m = t("c.s")
      else
        m = "Failed to created Data Store"
      end
    else
      m = t("c.f")
    end
    redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: m
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

  def map
    if @sudo[1]
      gon.mode = true
      render layout: "data_stores"
    else
      redirect_to _account_project_data_store_path(@core_project.account, @core_project, @data_store)
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

  def publish #PUBLISH TO CDN Functionality
    Core::S3File::UploadWorker.perform_async("DataStore", @data_store.id,@alknfalkfnalkfnadlfkna)
    redirect_to _account_project_path(@account,@core_project), notice: t("publish")
  end

  def clone
    begin
      new_table_name = Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/clone", {:token => @alknfalkfnalkfnadlfkna}, :format => :json
      @data_store.increase_clone_count
      d = @data_store.create_clone(new_table_name["table_name"], params[:core_data_store][:clone_to_core_project_id])
      redirect_to _account_project_data_store_path(d.account, d.core_project, d), notice: t("clone.s")
    rescue
      redirect_to :back, alert: t("clone.f")
    end
  end

  def index_all
    condition = "is_public = true"
    if account_signed_in?
      acc_id = current_user.accounts.pluck(:parent_id).to_s.gsub("[", "(").gsub("]", ")")
      if acc_id.present?
        condition += " OR account_id IN #{acc_id}"
      end
    end
    projects = Core::Project.where(condition)
    @selected_value = ""
    if params[:q].present? and params[:search].present?
      search_type = params[:search]
      @selected_value = search_type
      if search_type == "data"
        @data_stores = Core::DataStore.where(core_project_id: projects.pluck(:id) ).includes(:core_project).includes(:account).text_search(params[:q]).page params[:page]
      elsif search_type == "project"
        @core_projects = projects.text_search(params[:q]).page params[:page]
      elsif search_type == "user"
        @accounts = Core::Account.text_search(params[:q]).page params[:page]
      end
    else
      @data_stores = Core::DataStore.where(core_project_id: projects.pluck(:id)).includes(:core_project).includes(:account).page params[:page]
    end
  end

  def csv
    s = "/tmp/#{SecureRandom.hex(24)}.csv"
    @data_store.generate_file_in_tmp(s,@alknfalkfnalkfnadlfkna)
    send_data IO.read(s), :type => "application/vnd.ms-excel", :filename => "#{@data_store.slug}.csv", :stream => false
    File.delete(s)
  end

  def mark_as_dictionary
    @data_store.update_attributes({genre_class: "dictionary"})
    redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: t("dict.s")
  end

  def mark_as_dataset
    @data_store.update_attributes({genre_class: "dataset"})
    redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store),notice: t("dict.c")
  end

  def append_rows
    @data_stores = @core_project.data_stores.where("id != ?", @data_store.id)
  end

  def commit_append
    data_store_id = params["core_data_store"]["append_data_store_id"]
    append_table_name = Core::DataStore.select(:table_name).where(:id => data_store_id)
    append_table_name = append_table_name.to_a[0].table_name
    if append_table_name
      begin
        response = Nestful.post REST_API_ENDPOINT + "#{@account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/append_dataset", {:token => @alknfalkfnalkfnadlfkna, :source_table_name => append_table_name}
      rescue Exception => e
        e = JSON.parse(e.response.body)
        error = e["error"]
      end
    else
      error = "No dataset to append."
    end
    if !error
      redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: "Rows Appended."
    else
      @data_stores = @core_project.data_stores.where("id != ?", @data_store.id)
      @errors = e
      render :append_rows, alert: error
    end
  end

  def assign_metadata
  end

  def update_assign_metadata
    if @data_store.update_attributes(meta_description: params[:meta_description], source_url: params[:source_url])
      redirect_to _account_project_path(@core_project.account, @core_project), notice: t("u.s")
    else
      render :assign_metadata, alert: t("u.f")
    end
  end

  def recalibrate_metadata
    begin
      Nestful.get REST_API_ENDPOINT + "#{@core_project.account.slug}/#{@core_project.slug}/#{@data_store.slug}/grid/analyse_datatypes", {:token => @alknfalkfnalkfnadlfkna}, :format => :json 
      is_success = true
    rescue
      is_success = false
    end
    if is_success
      redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), notice: t("recalibrate_metadata.s")
    else
      redirect_to _edit_account_project_data_store_path(@core_project.account, @core_project, @data_store), alert: t("recalibrate_metadata.f")
    end
  end

  def open_data
    @projects = []
    @data_stores = []
    file_type = []
    file_type << 'GeoJson'  if params[:geojson]  and !params[:geojson].blank?
    file_type << 'TopoJson' if params[:topojson] and !params[:topojson].blank?

    unless params[:search].nil? or params[:search].blank?
      if current_account.nil?
        if params[:content] == "datasets"
          @projects = Core::Project.where("is_public = true")
        end
      else
        if params[:content] == "datasets"
          @projects = Core::Project.where("is_public = true OR id IN (?)", current_account.core_projects.pluck(:id).uniq)
        end
      end
      if params[:content] == "datasets"
        @data_stores = Core::DataStore.where(core_project_id: @projects.pluck(:id)).where("name LIKE ? OR meta_description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%").page params[:page] unless @projects.nil?
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
