class StaticPagesController < ApplicationController

  before_action :sudo_public!

  def index
    if account_signed_in?
      p = Core::Project.first
      redirect_to account_project_impl_aggregations_path(p.account, p)
    end
  end
  
  def refer
    redirect_to new_account_registration_path(r: params[:r])
  end
  
end
