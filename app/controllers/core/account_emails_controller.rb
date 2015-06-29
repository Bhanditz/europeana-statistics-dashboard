class Core::AccountEmailsController < ApplicationController
  
  before_action :set_core_account_email, only:  [:destroy, :resend_confirmation]
  before_action :sudo_organisation_owner!, only: [:index,:create,:confirmation]
  before_action :authenticate_account!, only: [:confirmation]

  def index
    @core_account_emails = @account.core_account_emails
    @core_account_email  = Core::AccountEmail.new()
  end

  def create
    @core_account_email = Core::AccountEmail.new(core_account_email_params)
    @core_account_email.account_id = @account.id
    if @core_account_email.save
      CoreMailer.send_account_email_confirmation(@core_account_email,@account)
      redirect_to account_core_account_emails_path, notice: t("confirm.mail_sent")
    else 
      @core_account_emails = @account.core_account_emails
      render "index"
    end 
  end

  def confirmation
    @core_account_email = @account.core_account_emails.where(id: params[:id])
    if @core_account_email.first.present?
      @core_account_email = @core_account_email.first
      if params[:confirmation_token].present? and @core_account_email.confirmation_token == params[:confirmation_token]
        @core_account_email.confirmed_at = Time.now 
        if @core_account_email.save
          Core::Permission.where(email: @core_account_email.email).update_all(account_id: @core_account_email.account_id, status:  Constants::STATUS_A)
          redirect_to account_core_account_emails_path(@account), notice: t("confirm.s")
        else
          redirect_to account_core_account_emails_path(@account), alert: t("confirm.f")
        end
      else
        redirect_to  account_core_account_emails_path(@account), alert: t("confirm.f")
      end
    else
      redirect_to  dashboard_path(@account), alert: t("confirm.pd")
    end
  end

  def resend_confirmation
    CoreMailer.send_account_email_confirmation(@core_account_email,@account)
    redirect_to account_core_account_emails_path, notice: t("confirm.mail_sent")
  end

  def destroy
    Core::Permission.where(email: @core_account_email.email).update_all(account_id: nil, status:  Constants::STATUS_I)
    @core_account_email.destroy
    redirect_to account_core_account_emails_path, notice: t("d.s")
  end

  private
  
  def set_core_account_email
    @core_account_email = @account.core_account_emails.find(params[:id])
  end

  def core_account_email_params
    params.require(:core_account_email).permit(:account_id, :email)
  end
  
end
