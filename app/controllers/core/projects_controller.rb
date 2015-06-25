class Core::ProjectsController < ApplicationController
  
  before_action :sudo_project_member!, only: [:members, :edit]
  before_action :sudo_project_owner!, only: [:destroy, :update]
  before_action :sudo_public!, only: [:show]
  before_action :sudo_organisation_owner!, only: [:new, :create]
  before_action :set_project, only: [:edit, :update, :destroy, :members]
  
  #---------------------------------------------------------------------------------------------------
  # CRUD

  def new
    @core_project = Core::Project.new
  end
  
  def show
    @data_stores = @core_project.data_stores.includes(:core_project).includes(:clone_parent).includes(:account).where(parent_id: nil).page params[:page]
    @data_stores_count = @core_project.data_stores.count
    @not_first_data_store = @data_stores_count != 0
    if true
      @vizs_count = @core_project.vizs.count
      @not_first_viz = @vizs_count != 0
    end
    if @sudo[1]
      if @can_host_custom_dashboard
        @custom_dashboards_count = @core_project.custom_dashboards.count
        @not_first_custom_dashboard = @custom_dashboards_count != 0
      end
    end
    @somethings_added = (@not_first_data_store or @not_first_viz or (@not_first_config_editor and (@not_first_custom_dashboard and @can_host_custom_dashboard)))
    @somethings_not_added = (!@not_first_data_store or (!@not_first_config_editor and (!@not_first_custom_dashboard and @can_host_custom_dashboard)))
    @pending_data_store_pulls = @core_project.core_data_store_pulls
    if params[:d].present? and params[:d_id].present?
      @dependent_to_destroy = params[:d]
      @data_store = @core_project.data_stores.find(params[:d_id])
      @url =  @dependent_to_destroy == "visualizations" ? _visualizations_account_project_data_store_url(@account,@core_project,@data_store) : "here,the url for maps will come"
    end
  end

  def edit
    @core_token  = Core::Token.new
    @core_tokens = @core_project.core_tokens.where.not(name: "rumi-weblayer-api").includes(:account)
  end

  def create
    @core_project = Core::Project.new(core_project_params)
    if @core_project.save
      redirect_to _account_project_path(@core_project.account, @core_project), notice: t("c.s")
    else
      flash.now.alert = t("c.f")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @core_project.update(core_project_params)
        format.html { redirect_to _edit_account_project_path(@core_project.account, @core_project), notice: t("u.s") }
        format.json { head :ok , notice: t("u.s")}
        #format.json { render :show, status: :updated, location: @core_project, notice: t("u.s") }
      else
        format.html { 
          @core_token  = Core::Token.new
          @core_tokens = @core_project.core_tokens.includes(:account)
          flash.now.alert = t("u.f")
          render :edit
        }
        format.json { render json: @core_project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @core_project.destroy
    if @core_project.errors.present?
      redirect_to _edit_account_project_path(@core_project.account, @core_project),alert: t("d.f")
    else
      redirect_to root_url, notice: t("d.s")
    end
  end
  
  #---------------------------------------------------------------------------------------------------
  # OTHER
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def members
    @permission = Core::Permission.new
    @permissions = @core_project.core_permissions.includes(:account)
  end
    
  #---------------------------------------------------------------------------------------------------

  private
  
  def set_project
    @core_project = Core::Project.where(account_id: @account.id).friendly.find(params[:id].blank? ? params[:project_id] : params[:id])
  end

  def core_project_params
    params.require(:core_project).permit(:account_id, :name, :is_public, 
                                    :description, :license) #hstore - properties
  end
  
end
