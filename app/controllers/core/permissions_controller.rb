# == Schema Information
#
# Table name: core_permissions
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  role            :string
#  email           :string
#  status          :string
#  invited_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  is_owner_team   :boolean
#  created_by      :integer
#  updated_by      :integer
#  core_project_id :integer
#

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
      CoreMailer.invite_into_project(current_account, @permission.email, @permission.core_project).deliver
      redirect_to members_account_core_project_path(@account, @permission.core_project)
    else
      redirect_to :back, alert: t("c.f") #RP_TO_IMPROVE LATER
    end
  end
  
  def destroy
    project = @permission.core_project
    @permission.destroy
    redirect_to members_account_core_project_path(project.account, project), notice: t("d.s")
  end
  
  #------------------------------------------------------------------------------------------------------------------
  # OTHER
  
  #------------------------------------------------------------------------------------------------------------------

  private
  
  def set_permission
    @permission = Core::Permission.find("#{h params[:id]}")
  end

  def core_permission_params
    params.require(:core_permission).permit(:account_id, :role, :email, :status, :invited_at, :core_project_id)
  end
  
end
