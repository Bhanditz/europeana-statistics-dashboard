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

  def dictionaries
    @data_store_dictionaries_to_approve = Core::DataStore.where(genre_class: "dictionary")
  end

  def verify_or_unverify_dictionaries
    data_store = Core::DataStore.find(params[:id])
    data_store.update_attributes({is_verified_dictionary: !data_store.is_verified_dictionary})
    redirect_to dictionaries_core_admins_path, notice: t("u.s")
  end
  
end
