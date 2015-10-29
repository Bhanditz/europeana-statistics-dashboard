class StaticPagesController < ApplicationController

  before_action :sudo_public!

  def index
    if account_signed_in?
      p = Core::Project.first
      redirect_to _account_project_path(p.account, p)
    else
      redirect_to new_account_session_path
    end
  end
  
end
