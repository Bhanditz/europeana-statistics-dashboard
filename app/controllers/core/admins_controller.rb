class Core::AdminsController < ApplicationController
  
  before_action :sudo_admin!
  
  def accounts
    @users = Account.joins(:cerebro_account).where(accountable_type: Constants::ACC_U).includes(:cerebro_account).order(:id).page params[:page]
  end

  def organizations
    @users = Account.where(accountable_type: Constants::ACC_O).order(:id).page params[:page]
  end

  def referrals
    @referrals = Core::Referral.where(is_eligible: false).includes(:friend).includes(:referrer)
  end
  
  def index
    @accounts = Account.all.where(accountable_type: Constants::ACC_U).count
    @organisations = Account.all.where(accountable_type: Constants::ACC_O).count
    @projects = Core::Project.all.count
  end

  def dictionaries
    @data_store_dictionaries_to_approve = Core::DataStore.where(genre_class: "dictionary")
  end

  def map_files
    @map_files_to_approve = Core::MapFile.where.not("properties -> 'cdn_published_url' = 'NULL'").page(params[:page]).per(30)
  end
  
  def approve_referral
    core_referral = Core::Referral.find(params[:id])
    core_referral.is_eligible = true
    if core_referral.save
      redirect_to referrals_core_admins_path, notice: t("u.s")
    else
      @referrals = Core::Referral.where(is_eligible: false).includes(:friend).includes(:referrer)
      flash.now.alert = t("u.f")
      render :referrals
    end
  end

  def verify_or_unverify_dictionaries
    data_store = Core::DataStore.find(params[:id])
    data_store.update_attributes({is_verified_dictionary: !data_store.is_verified_dictionary})
    redirect_to dictionaries_core_admins_path, notice: t("u.s")
  end

  def verify_or_unverify_map_files
    map_file = Core::MapFile.find(params[:id])
    map_file.update_attributes({is_verified: !map_file.is_verified})
    redirect_to map_files_core_admins_path, notice: t("u.s")
  end
  
end
