class Core::ReferralGiftsController < ApplicationController
  before_action :sudo_organisation_owner!
  
  def update
    @core_referral_gift =  @account.core_referral_gift.where(referral_id: core_referral_gift_params[:referral_id]).first
    @core_referral_gift.project_id = core_referral_gift_params[:project_id]
    if @core_referral_gift.save
      redirect_to _referrals_path, notice: t("u.s")
    else
      @organisations  = @account.organisations
      @core_referrals = @account.core_referrals.includes(:friend).includes(:core_referral_gift)
      @core_projects  = @account.core_projects
      flash.now.alert = t("u.f")
      render "accounts/referrals"
    end
  end

  private
  def core_referral_gift_params
    params.require(:core_referral_gift).permit(:referral_id,:project_id)
  end
end