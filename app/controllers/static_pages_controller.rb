class StaticPagesController < ApplicationController

  before_action :sudo_public!

  def index
    if account_signed_in?
      redirect_to dashboard_path(current_account)
    end
  end
  
  def tour
  end
  
  def refer
    redirect_to new_account_registration_path(r: params[:r])
  end
  
  def privacy
  end
  
  def roadmap
  end
  
  def enterprise
  end
  
  def open
  end
  
  def terms
  end
  
  def case_studies
  end
  
  def pricing
  end
  
  def security
  end
  
  def data_journalism
    render "static_pages/use_cases/data_journalism"
  end
  
  def visualizations
    render "static_pages/use_cases/visualizations"
  end
  
  def publish_open_data
    render "static_pages/use_cases/publish_open_data"
  end
    
end
