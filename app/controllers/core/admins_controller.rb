class Core::AdminsController < ApplicationController
  
  before_action :sudo_admin!

  def index
    @accounts = Account.all.count
    @projects = Core::Project.all.count
  end

end
