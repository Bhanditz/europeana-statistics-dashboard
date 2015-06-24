class Core::AdminsController < ApplicationController
  
  before_action :sudo_admin!
  
  def organizations
    @users = Account.where(accountable_type: Constants::ACC_O).order(:id).page params[:page]
  end

  def index
    @accounts = Account.all.where(accountable_type: Constants::ACC_U).count
    @organisations = Account.all.where(accountable_type: Constants::ACC_O).count
    @projects = Core::Project.all.count
  end

end
