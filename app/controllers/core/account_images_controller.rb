class Core::AccountImagesController < ApplicationController
  before_action :sudo_organisation_owner!
  before_action :set_core_account_image, only: [:update,:destroy]

  def create
    @core_account_image = Core::AccountImage.new(core_account_image_params)
    if @core_account_image.save
      Core::AccountImage::UploadWorker.perform_async(@core_account_image.id)
      redirect_url = @core_account_image.account.is_user_account? ? _edit_account_path(@account) : edit_core_organisation_path(@account)
      redirect_to redirect_url,notice: t("account_image.uploading")
    else
      if @core_account_image.account.is_user_account?
        @organisations = current_account.organisations
        render "accounts/edit"
      else
        render "core/organisations/edit"
      end
    end
  end

  def update
    if params[:core_account_image][:image_url].present?
      @core_account_image.image_url = params[:core_account_image][:image_url]
      @core_account_image.filesize = (params[:core_account_image][:image_url].tempfile.size.to_f/1000).round(2)
      if @core_account_image.save
        Core::AccountImage::UploadWorker.perform_async(@core_account_image.id)
        redirect_url = @core_account_image.account.is_user_account? ? _edit_account_path(@account) : edit_core_organisation_path(@account)
        redirect_to redirect_url,notice: t("account_image.uploading")
      else
        if @core_account_image.account.is_user_account?
          @organisations = current_account.organisations
          render "accounts/edit"
        else
          render "core/organisations/edit"
        end
      end
    else
      flash.now.alert = t("u.f")
      if @core_account_image.account.is_user_account?
          @organisations = current_account.organisations
          render "accounts/edit"
        else
          render "core/organisations/edit"
        end
    end
  end

  def destroy
    @core_account_image.update_attribute(:marked_to_be_deleted, "true")
    Core::AccountImage::DestroyWorker.perform_async(@core_account_image.id)
    redirect_url = @core_account_image.account.is_user_account? ? _edit_account_path(@account) : edit_core_organisation_path(@account)
    redirect_to redirect_url,notice: t("d.s")
  end

  private
    def set_core_account_image
      @core_account_image = @account.core_account_image
    end

    def core_account_image_params
      params.require(:core_account_image).permit(:account_id,:filetype, :image_url, :filesize)
    end
end
