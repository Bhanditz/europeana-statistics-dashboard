require 'json'
class Core::VizsController < ApplicationController
  layout "vizs", except: [:index, :data_stores]

  before_action :sudo_project_member!, except: [:show, :data_stores, :index,:embed]
  before_action :sudo_public!, only: [:show, :data_stores, :index,:embed]
  before_action :set_viz, only: [:show, :edit, :update,:update_only_query, :destroy, :embed]
  before_action :set_data_store, except: [:index]
  before_action :set_ref_charts, only: [:new, :create]
  before_action :set_rumi_params,only: [:show,:edit, :update,:update_only_query,:embed]
  before_action :set_token
  after_action :set_response_header, only: [:embed]

  def index
    @vizs = @core_project.vizs.order(:created_at).page params[:page]
  end

  def data_stores
    @vizs = @data_store.vizs.order(:created_at).page params[:page]
    if @vizs.first.blank?
      redirect_to _new_visualizations_account_project_data_store_path(@core_project.account, @core_project,@data_store)
    end
  end

  def show
    @chart = @viz.ref_chart
    @initializer = @chart.api
    @all_core_themes = Core::Theme.where(:account_id => [@account.id,nil])
    begin
      data = Nestful.post "#{REST_API_ENDPOINT}/data/#{@viz.datagram_identifier}/q", account_slug: @account.slug,token: @alknfalkfnalkfnadlfkna
      gon.data_file  = JSON.parse(data.body)["data"]
    rescue
    end
    @data_format = @viz.pykquery_object["dataformat"]
    gon.dataformat = @data_format
    render layout: "application"
  end

  def new
    @viz = Core::Viz.new
    @ref_charts =  Ref::Chart.where.not(slug: "grid")
    default_theme = Core::Theme.admin.where(name: "Default").first.config
    default_theme["credit_my_site_name"] = "Rumi"#TODO: Set smart logic w.r.t. attribution
    default_theme["credit_my_site_url"]  = "https://rumi.io"#TODO: Set smart logic w.r.t. attribution
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
      @chart_slug = @chart_name == "Pulse" ? "pulse" : @chart_name == "Pyramid" ? "pyramid" : @chart_name == "Treemap" ? "treemap" : ["panel-of-lines","panel-of-scatters"].include?(chart.slug) ? "panels-of-#{chart.slug.split("-")[2][0..-2]}".tr('-', '_').camelize(:lower) : chart.slug.tr('-', '_').camelize(:lower)
    end
    begin
      data = Nestful.post "#{REST_API_ENDPOINT}/data/#{@viz.datagram_identifier}/q", account_slug: @account.slug,token: @alknfalkfnalkfnadlfkna
      gon.data_file  = JSON.parse(data.body)["data"]
    rescue
    end
    @data_format = @viz.pykquery_object["dataformat"]
    gon.dataformat = @data_format
    @all_core_themes = Core::Theme.where(:account_id => [@account.id,nil])
  end

  def create
    @viz = Core::Viz.new(core_viz_params)
    @viz.core_project_id = @core_project.id
    @viz.core_data_store_id = @data_store.id
    @viz.pykquery_object = JSON.parse(core_viz_params[:pykquery_object])
    @viz.config = JSON.parse(core_viz_params[:config])
    if @viz.save
      redirect_to _edit_visualization_account_project_data_store_path(@core_project.account, @core_project, @data_store,@viz), notice: t("c.s")
    else
      render action: :new
    end
  end

  def update
    @viz.update(core_viz_params)
    @viz.config = JSON.parse(params[:core_viz][:config]) if params[:core_viz][:config].present? 
    if @viz.save
      redirect_to _edit_visualization_account_project_data_store_path(@account, @data_store.core_project, @data_store,@viz), notice: t("u.s")
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

  def update_only_query
    pykquery_object = @viz.pykquery_object
    pykquery_object["dataformat"] = core_viz_params["dataformat"].blank? ? "csv" : core_viz_params["dataformat"]
    @viz.pykquery_object = pykquery_object
    @viz.pykquery_object_will_change!
    @viz.save
    redirect_to _edit_visualization_account_project_data_store_path(@account, @data_store.core_project, @data_store,@viz), notice: t("u.s")
  end

  def destroy
    @viz.destroy
    redirect_to  :back, notice: t("d.s")
  end

  def embed
    if @core_project.ref_plan.can_publish_visualizations != "TRUE"
      redirect_to _visualization_account_project_data_store_path(@account, @data_store.core_project, @data_store,@viz), alert: t("pd.sudo_embed!")
    else
      begin
        data = Nestful.post "#{REST_API_ENDPOINT}/data/#{@viz.datagram_identifier}/q", account_slug: @account.slug,token: @alknfalkfnalkfnadlfkna
        gon.data_file = JSON.parse(data.body)["data"]
      rescue
      end
      @chart = @viz.ref_chart
      @initializer = @chart.api
      @data_format = @viz.pykquery_object["dataformat"]
      gon.dataformat = @data_format
      render layout: "embed"
    end
  end

  private

  def set_token
    @alknfalkfnalkfnadlfkna = @account.core_tokens.where(core_project_id: @core_project.id).first.api_token
    gon.token = @alknfalkfnalkfnadlfkna
  end

  def set_ref_charts
    @ref_charts = Ref::Chart.all
  end

  def set_viz
    @viz = Core::Viz.find(params[:id])
  end

  def set_data_store
    if params[:data_store_id].present?
      @data_store = @core_project.data_stores.where(slug: params[:data_store_id]).first
    elsif params[:data_id].present?
      @data_store = @core_project.data_stores.where(slug: params[:data_id]).first
    end
  end

  def set_rumi_params
    gon.rumiparams = "#{@account.username.parameterize}/#{@core_project.slug}/#{@data_store.slug}/"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def core_viz_params
    params.require(:core_viz).permit(:name,:core_project_id, :core_data_store_id, :properties, :pykquery_object, :ref_chart_combination_code, :refresh_freq_in_minutes, :is_static,:config,:dataformat)
  end

  def set_response_header
    response.headers.except! 'X-Frame-Options'
  end

end
