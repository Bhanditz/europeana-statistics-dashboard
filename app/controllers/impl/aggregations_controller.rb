class Impl::AggregationsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_impl_aggregation, only: [:show,:edit, :update, :destroy, :restart_worker, :datacasts,:reset_country_data]

  def index
    @impl_aggregations = @core_project.impl_aggregations.countries.includes(:impl_report)
    @impl_aggregation = Impl::Aggregation.new
  end

  def edit
    if @impl_aggregation.genre == 'country'
      @impl_providers = @impl_aggregation.child_providers.includes(:impl_report)
      @impl_data_providers = @impl_aggregation.child_data_providers.includes(:impl_report)
    elsif @impl_aggregation.genre == "provider"
      @impl_countries = @impl_aggregation.parent_countries.includes(:impl_report)
      @impl_data_providers = @impl_aggregation.child_data_providers.includes(:impl_report)
    else
      @impl_countries = @impl_aggregation.parent_countries.includes(:impl_report)
      @impl_providers = @impl_aggregation.parent_providers.includes(:impl_report)
      @impl_data_sets = @impl_aggregation.impl_data_sets
    end
    @core_datacasts = @impl_aggregation.core_datacasts
  end

  def show
  end

  def create
    @impl_aggregation = Impl::Aggregation.new(impl_aggregation_params)
    @impl_aggregation.created_by = current_account.id
    @impl_aggregation.updated_by = current_account.id
    if @impl_aggregation.save
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project,@impl_aggregation), notice: t("c.s")
    else
      render :index
    end
  end

  def update
    if @impl_aggregation.update(impl_aggregation_params)
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t("u.s")
    else
      render :edit
    end
  end

  def destroy
    @impl_aggregation.destroy
    redirect_to account_project_impl_aggregations_path(@core_project.account, @core_project), notice: t("d.s")
  end

  def restart_worker
    @impl_aggregation.restart_all_jobs
    redirect_to :back, notice: t("aggregation.refreshed_all_jobs")
  end

  def reset_country_data
    if @impl_aggregation.genre == "country"
      Impl::Country::ResetData.perform_async(@impl_aggregation.id)
    end
    redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t("aggregation.refreshed_all_jobs")
  end

  private

    def set_impl_aggregation
      @impl_aggregation = Impl::Aggregation.find("#{h (params[:id])}")
    end

    def impl_aggregation_params
      params.require(:impl_aggregation).permit(:core_project_id, :genre, :name, :wikiname, :created_by, :updated_by, :last_requested_at, :last_updated_at, :provider_ids)
    end
end
