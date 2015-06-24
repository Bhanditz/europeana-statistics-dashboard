class Core::OrganisationsController < ApplicationController
  
  before_action :sudo_account!
  before_action :sudo_organisation_owner!, only: [:edit, :update, :members]
  before_action :sudo_admin!, only: [:make_enterprise_account]
  before_action :organisation_counts
  
  def index
    @enable_express_tour = true
    @account = Account.new
  end
  
  def sign_up
    if account_signed_in?
      redirect_to root_url, alert: "Already signed in."
    else
      render layout: "empty"
    end
  end
  
  def edit
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def create
    @account = Account.new(account_params)
    @account.skip_confirmation!
    @account.password = Devise.friendly_token.first(8)
    if @account.save
      team = Core::Team.new(organisation_id: @account.id, name: "Owners", role: Constants::ROLE_O, is_owner_team: true)
      team.save
      Core::Permission.create!(account_id: current_account.id, organisation_id: @account.id, role: Constants::ROLE_O, email: current_account.email, status: "Accepted", core_team_id: team.id)
      redirect_to core_organisations_path, notice: t("c.s")
    else
      flash.now.alert = t("c.f")
      render :index
    end
  end
  
  def update
    if @account.update(account_params)
      redirect_to edit_core_organisation_path(@account), notice: t("u.s")
    else
      @organisations = current_account.organisations
      flash.now.alert = t("u.f")
      render :edit
    end
  end
  
  def make_enterprise_account
    o = Account.friendly.find(params[:organisation_id])
    o.update_attributes(is_enterprise_organisation: "true")
    redirect_to organizations_core_admins_path
  end
  
  def whosonline
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def members
    @invites = @account.accounts.where("account_id is null").pluck(:email).uniq
    @accounts = Account.where(id: @account.accounts.where("account_id is not null").pluck(:account_id))
  end
  
  def events
    @our_actions = @account.session_actions_o.includes(:account).includes(:organisation).page params[:page]#.includes(:obj)
  end
  
  private
  
  def account_params
    params.require(:account).permit(:username, :accountable_type, :email, :authentication_token,
            :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company) #hstore - properties  
  end
  
  #------------------------------------------------------------------------------------------
    
end
