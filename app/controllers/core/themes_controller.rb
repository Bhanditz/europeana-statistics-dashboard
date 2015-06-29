class Core::ThemesController < ApplicationController
    
  before_action :sudo_organisation_owner!
  before_action :set_core_theme, only: [:show, :edit, :update, :destroy]
  before_action :set_admin_core_themes, only: [:new,:edit, :index, :create,:update]

  def index
    @my_core_themes = @account.custom_themes
  end

  def new
    @core_theme    = Core::Theme.new
    @visualization = {}
    @visualization['config'] = @all_core_themes.first.config
    @initializer   = "PykCharts.oneD.pie"
    @chart_name    = "Pie"
    @data_file     = "https://s3-ap-southeast-1.amazonaws.com/chartstore.io-data/pie.csv"
    @visualization['genre']  = "One Dimensional Charts"
  end

  def edit
    @visualization = {}
    @visualization['config'] = @core_theme.config
    @initializer   = "PykCharts.oneD.pie"
    @chart_name    = "Pie"
    @data_file     = "https://s3-ap-southeast-1.amazonaws.com/chartstore.io-data/pie.csv"
    @visualization['genre']  = "One Dimensional Charts"
  end

  def create
    name       = params[:core_theme][:name]
    account_id = @account.id
    config     = JSON.parse(params[:core_theme][:config])
    @core_theme = Core::Theme.new({name: name, config: config, account_id: account_id})
    if @core_theme.save
      redirect_to core_organisation_themes_path(@account), notice: t("c.s")
    else
      @visualization = {}
      @visualization['config'] = @core_theme.config
      @initializer   = "PykCharts.oneD.pie"
      @chart_name    = "Pie"
      @data_file     = "https://s3-ap-southeast-1.amazonaws.com/chartstore.io-data/pie.csv"
      @visualization['genre']  = "One Dimensional Charts"
      flash.now.alert = t("c.f")
      render :new
    end
  end

  def update
    name       = params[:core_theme][:name]
    config     = JSON.parse(params[:core_theme][:config])
    #account_id will not be updated
    if @core_theme.update({name: name, config: config}) 
      redirect_to edit_core_organisation_theme_path(@account, @core_theme), notice: t("u.s")
    else
      @visualization = {}
      @visualization['config'] = @core_theme.config
      @initializer   = "PykCharts.oneD.pie"
      @chart_name    = "Pie"
      @data_file     = "https://s3-ap-southeast-1.amazonaws.com/chartstore.io-data/pie.csv"
      @visualization['genre']  = "One Dimensional Charts"
      flash.now.alert = t("u.f")
      render :edit
    end
  end

  def destroy
    @core_theme.destroy
    redirect_to core_organisation_themes_path(@account), notice: t("d.s")
  end

  private


  def set_core_theme
    @core_theme = Core::Theme.find(params[:id])
  end

  def core_theme_params
    params.require(:core_theme).permit(:account_id, :name, :sort_order, :config, :image_url)
  end

  def set_admin_core_themes
    @all_core_themes = Core::Theme.all.admin
  end
  
end
