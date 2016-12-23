# frozen_string_literal: true
# == Schema Information
#
# Table name: impl_aggregations
#
#  id              :integer          not null, primary key
#  core_project_id :integer
#  genre           :string
#  name            :string
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :string
#  error_messages  :string
#  properties      :hstore
#  last_updated_at :date
#

class Impl::AggregationsController < ApplicationController
  before_action :authenticate_account!, except: [:providers, :data_providers, :countries, :countrieslist]
  before_action :set_impl_aggregation, only: [:show, :edit, :update, :destroy, :restart_worker]
  layout :styleguide_aware_layout

  # Overview of all aggregations
  def index
    @impl_aggregations = @core_project.impl_aggregations.countries.includes(:impl_report)
    @impl_aggregation = Impl::Aggregation.new
  end

  # Edit the aggregation for the given ID
  def edit
    if @impl_aggregation.genre == 'country'
      @impl_providers = @impl_aggregation.child_providers.includes(:impl_report)
      @impl_data_providers = @impl_aggregation.child_data_providers.includes(:impl_report)
    elsif @impl_aggregation.genre == 'provider'
      @impl_countries = @impl_aggregation.parent_countries.includes(:impl_report)
      @impl_data_providers = @impl_aggregation.child_data_providers.includes(:impl_report)
    else
      @impl_countries = @impl_aggregation.parent_countries.includes(:impl_report)
      @impl_providers = @impl_aggregation.parent_providers.includes(:impl_report)
      @impl_data_sets = @impl_aggregation.impl_data_sets
    end
    @core_datacasts = @impl_aggregation.core_datacasts
  end

  # Create a new aggregation in the database.
  def create
    @impl_aggregation = Impl::Aggregation.new(impl_aggregation_params)
    @impl_aggregation.created_by = current_account.id
    @impl_aggregation.updated_by = current_account.id
    if @impl_aggregation.save
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t('c.s')
    else
      render :index
    end
  end

  # Update an aggregation with the given ID.
  def update
    if @impl_aggregation.update(impl_aggregation_params)
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t('u.s')
    else
      render :edit
    end
  end

  # Destroy an aggregation with the given ID.
  def destroy
    @impl_aggregation.destroy
    redirect_to account_project_impl_aggregations_path(@core_project.account, @core_project), notice: t('d.s')
  end

  # Invokes a method that run's a all the jobs to fetch all the data again.
  def restart_worker
    @impl_aggregation.restart_all_jobs
    redirect_to :back, notice: t('aggregation.refreshed_all_jobs')
  end

  # Render Provider page.
  def providers
  end

  # Render Data Providers page.
  def data_providers
  end

  # Render Countries page.
  def countries
  end

  # Render Country list page.
  def countrieslist
  end

  private

  def set_impl_aggregation
    @impl_aggregation = Impl::Aggregation.find(params[:id].to_s)
  end

  def impl_aggregation_params
    params.require(:impl_aggregation).permit(:core_project_id, :genre, :name, :wikiname, :created_by, :updated_by, :last_requested_at, :last_updated_at, :provider_ids)
  end

  def styleguide_aware_layout
    %w(providers data_providers countries countrieslist).include?(action_name) ? false : 'application'
  end
end
