# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::TeamProjectsController < ApplicationController
  
  before_action :sudo_organisation_owner!

  def add
    project = Core::Project.find(params[:p])
    Core::TeamProject.create!(core_team_id: params[:c], core_project_id: params[:p])
    redirect_to members_account_core_project_path(project.account, project), notice: t("c.s")
  end

  def destroy
    @core_team_project = Core::TeamProject.find(params[:id])
    project = @core_team_project.core_project
    @core_team_project.destroy
    redirect_to members_account_core_project_path(project.account, project), notice: t("d.s")
  end
  
end
