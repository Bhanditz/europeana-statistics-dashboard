# == Schema Information
#
# Table name: impl_reports
#
#  id                     :integer          not null, primary key
#  impl_aggregation_id    :integer
#  core_template_id       :integer
#  name                   :string
#  slug                   :string
#  html_content           :text
#  variable_object        :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_autogenerated       :boolean          default(FALSE)
#  core_project_id        :integer          default(1)
#  impl_aggregation_genre :string
#

class Impl::ReportsController < ApplicationController
  include Europeana::Styleguide

  layout :styleguide_aware_layout

  before_action :sudo_public!, only: [:show, :index]
  before_action :set_impl_report, only: [:show,:edit, :update, :destroy]
  before_action :set_gon_config_objects,only: [:show,:edit, :update,:new, :create]

  def index
    @impl_reports = Impl::Report.manual.order(updated_at: :desc)
  end

  def new
    @impl_report = Impl::Report.new
  end

  def create
    @impl_report = Impl::Report.new(impl_report_params)
    if @impl_report.save
      redirect_to edit_account_project_impl_report_path(@account,@core_project, @impl_report), notice: t("c.s")
    else
      render :new
    end
  end

  def show
  	selected_date = Date.today.at_beginning_of_month - 1
    gon.selected_year = selected_date.year
    gon.prev_month = Date::MONTHNAMES[selected_date.month - 1]
    gon.current_month = Date::MONTHNAMES[selected_date.month]
    gon.is_autogenerated = @impl_report.is_autogenerated
    gon.report_slug = @impl_report.slug
    gon.genre = @impl_report.impl_aggregation.genre if @impl_report.is_autogenerated
  end

  def edit
    @core_vizs = Core::Viz.manual
  end

  def update
    if @impl_report.update_attributes(impl_report_params)
      redirect_to edit_account_project_impl_report_path(@account,@core_project, @impl_report), notice: t("u.s")
    else
      render :edit
    end
  end

  def destroy
    @impl_report.destroy
    redirect_to account_project_impl_reports_path(@account, @core_project)
  end

  private

  def set_gon_config_objects
    @core_vizs = Core::Viz.manual
    gon.chart_config_objects = {}
    @core_vizs.each do |viz|
      gon.chart_config_objects[viz.name.parameterize("_")] = viz.config
    end
  end

  def set_impl_report
    if params[:impl_report_id].present?
      genre = params[:genre]
      @impl_report = Impl::Report.where(impl_aggregation_genre: genre).friendly.find(params[:impl_report_id])
    else
      @impl_report = Impl::Report.friendly.find(params[:id])
    end
  end

  def impl_report_params
    params.require(:impl_report).permit(:name, :html_content,:core_project_id,:variable_object)
  end

  def styleguide_aware_layout
    params[:action] == 'show' ? false : 'application'
  end
end
