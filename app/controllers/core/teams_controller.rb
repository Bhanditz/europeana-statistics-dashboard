# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::TeamsController < ApplicationController
  
  before_action :sudo_organisation_owner!, :organisation_counts
  before_action :set_core_team, only: [:show, :update, :destroy, :in]

  def index
    @core_teams = @account.core_teams
    @core_team = Core::Team.new
  end
  
  def in
    if params[:u]
      new_guy = Account.friendly.find(params[:u])
      new_id = new_guy.id
      email = new_guy.email
    elsif params[:e]
      new_id = nil
      email = params[:e]
    end
    if email.present?
      c = Core::Permission.where(organisation_id: @account.id, account_id: new_id, email: email, core_team_id: @core_team.id).first
      if c.blank?
        c = Core::Permission.new(organisation_id: @account.id, account_id: new_id, email: email, core_team_id: @core_team.id)
      end
      c.role = @core_team.role
      c.save
    end
    redirect_to core_organisation_team_path(@core_team.organisation, @core_team), notice: t("c.s")
  end

  def show
    @core_team_projects = @core_team.core_team_projects
    @in_team = @core_team.core_permissions.includes(:account)
    @permission = Core::Permission.new
    in_team_1 = @core_team.core_permissions.where("account_id IS NOT NULL").pluck(:account_id).uniq
    in_team_2 = @core_team.core_permissions.where("account_id IS NULL").pluck(:email).uniq
    if in_team_1.first.blank?
      @not_in_team_1 = Account.where(id: @account.accounts.where("account_id IS NOT NULL").pluck(:account_id).uniq)
    else
      @not_in_team_1 = Account.where(id: @account.accounts.where("account_id IS NOT NULL").where("account_id NOT IN (?)", in_team_1).pluck(:account_id).uniq)
    end
    if in_team_2.first.blank?
      @not_in_team_2 = @account.accounts.where("account_id IS NULL").pluck(:email).uniq
    else
      @not_in_team_2 = @account.accounts.where("account_id IS NULL").where("email NOT IN (?)", in_team_2).pluck(:email).uniq
    end
  end

  def create
    @core_team = Core::Team.new(core_team_params)
    if @core_team.save
      redirect_to core_organisation_teams_path(@account), notice: t("c.s")
    else
      @core_teams = @account.core_teams
      flash.now.alert = t("c.f")
      render :index
    end
  end

  def update
    if @core_team.update(core_team_params)
      redirect_to @core_team, notice: t("u.s")
    else
      flash.now.alert = t("u.f")
      render :show
    end
  end

  def destroy
    @core_team.destroy
    redirect_to core_organisation_teams_path(@account), notice: t("d.s")
  end

  private
  
  def set_core_team
    @core_team = @account.core_teams.find(params[:id])
  end

  def core_team_params
    params.require(:core_team).permit(:organisation_id, :name, :description, :role)
  end
    
end
