# frozen_string_literal: true
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

  before_action :authenticate_account!, only: [:index, :manual_report]
  before_action :set_impl_report, only: [:show, :edit, :update, :destroy, :manual_report]
  before_action :set_gon_config_objects, only: [:show, :edit, :update, :new, :create]

  # Overview of all manual Impl::Reports
  def index
    @impl_reports = Impl::Report.manual.order(updated_at: :desc)
  end

  # Creates a new instance of Impl::Report
  def new
    @impl_report = Impl::Report.new
  end

  # Saves the instance of Impl::Report to database.
  def create
    @impl_report = Impl::Report.new(impl_report_params)
    if @impl_report.save
      redirect_to account_project_impl_reports_path(@account, @core_project), notice: t('c.s')
    else
      render :new
    end
  end

  # Displays details of Impl::Report with a particular ID.
  def show
    @selected_date = Date.today.at_beginning_of_month - 1
    @current_month = Date::MONTHNAMES[@selected_date.month]
    gon.selected_year = @selected_date.year.to_s
    gon.prev_month = Date::MONTHNAMES[@selected_date.month - 1]
    gon.current_month = @current_month
    gon.is_autogenerated = @impl_report.is_autogenerated
    gon.report_slug = @impl_report.slug
    gon.genre = @impl_report.impl_aggregation.genre if @impl_report.is_autogenerated
    gon.top_digital_objects_identifier = @impl_aggregation.core_datacasts.top_digital_objects.first.identifier
  end

  # Render manual report creation page.
  def manual_report
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  # Edit details of Impl::Report with a particular ID.
  def edit
    @core_vizs = Core::Viz.manual
  end

  # Update details of Impl::Report with a particular ID.
  def update
    if @impl_report.update_attributes(impl_report_params)
      redirect_to account_project_impl_reports_path(@account, @core_project), notice: t('u.s')
    else
      render :edit
    end
  end

  # Destroy details of Impl::Report with a particular ID.
  def destroy
    @impl_report.destroy
    redirect_to account_project_impl_reports_path(@account, @core_project)
  end

  private

  def set_gon_config_objects
    @core_vizs = Core::Viz.manual
    gon.chart_config_objects = {}
    @core_vizs.each do |viz|
      gon.chart_config_objects[viz.name.parameterize('_')] = viz.config
    end
  end

  def set_impl_report
    if params[:impl_report_id].present?
      genre = params[:genre]
      @impl_report = Impl::Report.where(impl_aggregation_genre: genre).friendly.find(params[:impl_report_id])
    elsif params[:manual_report_id].present?
      @impl_report = Impl::Report.friendly.find(params[:manual_report_id])
    else
      @impl_report = Impl::Report.friendly.find(params[:id])
    end
    @impl_aggregation = @impl_report.impl_aggregation
  end

  def impl_report_params
    params.require(:impl_report).permit(:name, :html_content, :core_project_id, :variable_object)
  end

  def styleguide_aware_layout
    %w(show manual_report).include?(params[:action]) ? false : 'application'
  end
end
