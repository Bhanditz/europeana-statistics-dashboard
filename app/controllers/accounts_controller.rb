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

  before_action :authenticate_account!, only: [:dashboard, :edit, :update]

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

  # private

  def account_params
    params.require(:account).permit(:username, :email, :authentication_token,
      :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company, :confirmation_sent_at) #hstore - properties
  end

end
