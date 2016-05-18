# == Schema Information
#
# Table name: core_projects
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  slug       :string
#  properties :hstore
#  is_public  :boolean
#  created_at :datetime
#  updated_at :datetime
#  created_by :integer
#  updated_by :integer
#

class Core::ProjectsController < ApplicationController

  before_action :authenticate_account!, only: [:show]
  before_action :set_project, only: [:show]

  #---------------------------------------------------------------------------------------------------
  # CRUD

  def show
  end

  #---------------------------------------------------------------------------------------------------

  private

  def set_project
    @core_project = @account.core_projects.find(params[:project_id])
    # @core_project = Core::Project.where(account_id: @account.id).friendly.find(params[:id].blank? ? params[:project_id] : params[:id])
  end
end
