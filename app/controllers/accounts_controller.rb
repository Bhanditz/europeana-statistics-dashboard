class AccountsController < ApplicationController

  before_action :sudo_organisation_owner!, only: [:dashboard, :edit, :update, :digital_footprint, :revoke_session]
  before_action :sudo_public!, only: [:show]
  
  #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def show
    @enable_express_tour = true
    @organisations = @account.accounts.includes(:organisation)
    @has_organisation_accounts = @organisations.count > 1 ? true : false
    if @account.accountable_type == Constants::ACC_O
      @members = @account.accounts
    end
    if params[:content] == "projects"
      @core_projects = @account.core_projects.includes(:account).where(is_public: true)
    elsif params[:content] == "maps"
      @core_map_files = @account.core_map_files.where(is_public: true)
    end
  end

  def edit
    @enable_express_tour = true
    @organisations = current_account.organisations
  end

  def update
    if @account.update(account_params)
      redirect_to _edit_account_path(@account), notice: t("u.s")
    else
      @organisations = current_account.organisations
      flash.now.alert = t("u.f")
      render :edit
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  # OTHER
  
  def revoke_session
    c = Core::Session.where(session_id: params[:s]).first
    c.destroy
    redirect_to edit_account_registration_path(current_account), notice: t("d.s")
  end
  
  def digital_footprint
    @organisations = current_account.organisations
  end

  def dashboard
    @enable_express_tour = true
    @core_projects   = @account.core_projects.includes(:account).page(params[:page_projects]).per(30)
    organisation_ids = @account.organisations.pluck(:id).uniq
    core_project_ids = @account.core_projects.pluck(:id).uniq
  end
  
  private

  def account_params
    params.require(:account).permit(:username, :accountable_type, :email, :authentication_token,
      :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company, :confirmation_sent_at) #hstore - properties  
  end

end
