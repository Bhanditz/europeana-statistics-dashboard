class StaticPagesController < ApplicationController

  before_action :sudo_public!

  def index
    if account_signed_in?
      redirect_to dashboard_path(current_account)
    end
  end
  
  def refer
    redirect_to new_account_registration_path(r: params[:r])
  end
  
end
