require 'json'
class Core::VizsController < ApplicationController
  layout "vizs", except: [:index]

  before_action :sudo_project_member!, except: [:show, :index,:embed]
  before_action :sudo_public!, only: [:show, :index,:embed]
  before_action :set_viz, only: [:show, :edit, :update, :destroy, :embed]
  before_action :set_ref_charts, only: [:new, :create]
  after_action :set_response_header, only: [:embed]

  def index
    @vizs = @core_project.vizs.manual.includes(:ref_chart).order(created_at: :desc).page params[:page]
    if @vizs.blank?
      redirect_to new_account_core_project_viz_path(@account, @core_project)
    end
  end

  def show
  end

  def new
    ids_to_exclude = Impl::AggregationDatacast.all.pluck(:core_datacast_identifier).uniq
    @core_datacasts = @core_project.core_datacasts.where.not(identifier: ids_to_exclude).ready.order(created_at: :desc)
    @viz = Core::Viz.new
    @ref_charts =  Ref::Chart.where.not(slug: "grid")
    default_theme = Core::Theme.admin.where(name: "Default").first.config
    gon.default_theme = default_theme.to_json
  end

  def edit
    chart = @viz.ref_chart
    if chart.name != "Grid"
      @visualization = {}
      @visualization['genre'] = chart.genre
      @visualization['config'] = @viz.config
      @initializer = chart.api
      @chart_name = chart.name
      @chart_slug = @chart_name == "Choropleth" ? "world-oneLayer" : @chart_name == "Pulse" ? "pulse" : @chart_name == "Pyramid" ? "pyramid" : @chart_name == "Treemap" ? "treemap" : ["panel-of-lines","panel-of-scatters"].include?(chart.slug) ? "panels-of-#{chart.slug.split("-")[2][0..-2]}".tr('-', '_').camelize(:lower) : chart.slug.tr('-', '_').camelize(:lower)
    end
    gon.chart_config = @viz.config
    @all_core_themes = Core::Theme.admin
  end

  def create
    @viz = Core::Viz.new(core_viz_params)
    @viz.core_project_id = @core_project.id
    @viz.config = Core::Theme.default_theme.config unless ["Grid","One Number indicators"].include?(@viz.ref_chart.name)
    if @viz.save
      redirect_to edit_account_core_project_viz_path(@account, @core_project,@viz), notice: t("c.s")
    else
      @core_datacasts = @core_project.core_datacasts.ready.order(created_at: :desc)
      @ref_charts =  Ref::Chart.where.not(slug: "grid")
      default_theme = Core::Theme.admin.where(name: "Default").first.config
      gon.default_theme = default_theme.to_json
      render action: :new
    end
  end

  def update
    @viz.update(core_viz_params)
    @viz.config = JSON.parse(params[:core_viz][:config]) if params[:core_viz][:config].present? 
    if @viz.save
      redirect_to edit_account_core_project_viz_path(@account, @core_project,@viz), notice: t("u.s")
    else
      chart = @viz.ref_chart
      if chart.name != "Grid"
        @visualization = {}
        @visualization['genre'] = chart.genre
        @visualization['config'] = @viz.config
        @initializer = chart.api
        @chart_name = chart.name
        @chart_slug = @chart_name == "Pulse" ? "pulse" : @chart_name == "Treemap" ? "treemap" : ["panel-of-lines","panel-of-scatters"].include?(chart.slug) ? "panels-of-#{chart.slug.split("-")[2][0..-2]}".tr('-', '_').camelize(:lower) : chart.slug.tr('-', '_').camelize(:lower)
      end
      gon.pykquery_object = @viz.pykquery_object.to_json
      @all_core_themes = Core::Theme.where(:account_id => [@account.id,nil])
      flash.now.alert = t("u.f")
      render :edit
    end
  end

  def destroy
    @viz.destroy
    redirect_to :back, notice: t("d.s")
  end

  private

  def set_ref_charts
    @ref_charts = Ref::Chart.all
  end

  def set_viz
    @viz = Core::Viz.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def core_viz_params
    params.require(:core_viz).permit(:name,:core_project_id,:core_datacast_identifier,:filter_present, :filter_column_name, :filter_column_d_or_m, :properties, :ref_chart_combination_code)
  end

  def set_response_header
    response.headers.except! 'X-Frame-Options'
  end

end