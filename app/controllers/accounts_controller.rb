# == Schema Information
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  username               :string
#  email                  :string           default(""), not null
#  slug                   :string
#  properties             :hstore
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  confirmation_token     :string
#  unconfirmed_email      :string
#  created_at             :datetime
#  updated_at             :datetime
#  authentication_token   :string
#  devis                  :hstore
#  sign_in_count          :integer
#  confirmation_sent_at   :datetime
#  reset_password_sent_at :datetime
#

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
