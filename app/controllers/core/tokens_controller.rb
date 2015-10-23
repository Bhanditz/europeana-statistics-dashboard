class Core::TokensController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_core_token, only: [:destroy]
  
  def create
    @core_token = Core::Token.new(core_token_params)
    if @core_token.save
      redirect_to edit_account_core_project_path(@core_project.account, @core_project), notice: t("c.s")
    else
      @core_tokens = @core_project.core_tokens.includes(:account)
      flash.now.alert = t("c.f")
      render "/core/projects/edit"
    end
  end

  def destroy
    @core_token.destroy
    redirect_to edit_account_core_project_path(@core_project.account, @core_project), notice: t("d.s") 
  end

  private
  
  def set_core_token
    @core_token = Core::Token.find("#{h params[:id]}")
  end

  def core_token_params
    params.require(:core_token).permit(:account_id, :core_project_id, :name)
  end
    
end
