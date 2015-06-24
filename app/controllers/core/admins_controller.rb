class Core::AdminsController < ApplicationController
  
  before_action :sudo_admin!

  def index
    @accounts = Account.all.where(accountable_type: Constants::ACC_U).count
    @projects = Core::Project.all.count
  end

end
