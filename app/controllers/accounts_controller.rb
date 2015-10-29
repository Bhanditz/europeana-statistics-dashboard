class AccountsController < ApplicationController

  before_action :sudo_organisation_owner!, only: [:dashboard, :edit, :update]

  #------------------------------------------------------------------------------------------------------------------
  # CRUD

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to _edit_account_path(@account), notice: t("u.s")
    else
      flash.now.alert = t("u.f")
      render :edit
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  # OTHER
  
  def dashboard
    @core_projects   = @account.core_projects.includes(:account).page(h params[:page_projects]).per(30)
    core_project_ids = @account.core_projects.pluck(:id).uniq
  end
  
  # private

  def account_params
    params.require(:account).permit(:username, :email, :authentication_token,
      :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company, :confirmation_sent_at) #hstore - properties  
  end

end