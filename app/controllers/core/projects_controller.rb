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
