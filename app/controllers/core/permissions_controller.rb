# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::PermissionsController < ApplicationController
  
  before_action :sudo_organisation_owner!, :sudo_project_owner!
  before_action :set_permission, only: [:destroy]
  
  #------------------------------------------------------------------------------------------------------------------
  # CRUD
  
  def create
    @permission = Core::Permission.new(core_permission_params)
    @permission.set_account_id_if_email_found
    if @permission.save
      if @permission.organisation.is_user_account?
        CoreMailer.invite_into_project(current_account, @permission.email, @permission.core_projects.first).deliver
        redirect_to members_account_core_project_path(@permission.organisation, @permission.core_projects.first)
      else
        CoreMailer.invite_into_organisation(current_account, @permission.email, @permission.organisation).deliver
        redirect_to core_organisation_team_path(@permission.organisation, @permission.core_team), notice: t("c.s")
      end
    else
      if @permission.organisation.is_user_account?
        redirect_to :back, alert: t("c.f") #RP_TO_IMPROVE LATER
      else
        @account = @permission.organisation
        flash.now.alert = t("c.f")
        render "core/organisations/teams/index"
      end
    end
  end
  
  def destroy
    if @permission.organisation.is_user_account?
      project = @permission.core_projects.first 
      @permission.destroy
      redirect_to members_account_core_project_path(project.account, project), notice: t("d.s")
    else
      parent = @permission.organisation
      core_team = @permission.core_team
      @permission.destroy
      redirect_to core_organisation_team_path(parent, core_team), notice: t("d.s")
    end
  end
  
  #------------------------------------------------------------------------------------------------------------------
  # OTHER
  
  #------------------------------------------------------------------------------------------------------------------

  private
  
  def set_permission
    @permission = Core::Permission.find(params[:id])
  end

  def core_permission_params
    params.require(:core_permission).permit(:account_id, :role, :email, :status, :invited_at, :organisation_id, :core_team_id)
  end
  
end
