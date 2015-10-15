class Impl::AggregationsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_impl_aggregation, only: [:show,:edit, :update, :destroy, :restart_all_aggregation_workers, :datacasts]

  def index
    @impl_aggregations = @core_project.impl_aggregations.aggregations.includes(:impl_report)
    @impl_aggregation = Impl::Aggregation.new
  end

  def edit
    @impl_providers = @impl_aggregation.impl_providers
    @core_datacasts = @impl_aggregation.core_datacasts.includes(:core_db_connection).order(updated_at: :desc)
    @impl_provider = Impl::Provider.new
  end

  def show
  end

  def create
    @impl_aggregation = Impl::Aggregation.new(impl_aggregation_params)
    @impl_aggregation.created_by = current_account.id
    @impl_aggregation.updated_by = current_account.id
    @impl_aggregation.provider_ids = impl_aggregation_params[:provider_ids].split(",") unless impl_aggregation_params[:provider_ids].blank?
    if @impl_aggregation.save
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project,@impl_aggregation), notice: t("c.s")
    else
      render :index
    end
  end

  def update
    if @impl_aggregation.update(impl_aggregation_params)
      Aggregations::DatacastsBuilder.perform_async(@impl_aggregation.id)
      Aggregations::MediaTypesBuilder.perform_async(@impl_aggregation.id)
      Aggregations::WikiProfileBuilder.perform_async(@impl_aggregation.id)
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t("u.s")
    else
      render "impl/providers/index"
    end
  end

  def destroy
    @impl_aggregation.destroy
    redirect_to account_project_impl_aggregations_path(@core_project.account, @core_project), notice: t("d.s")
  end

  def restart_all_aggregation_workers
    @impl_aggregation.restart_all_jobs
    redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t("aggregation.refreshed_all_jobs")
  end

  private

    def set_impl_aggregation
      @impl_aggregation = Impl::Aggregation.includes(:impl_providers, :impl_aggregation_outputs, :impl_provider_outputs).find(params[:id])
    end

    def impl_aggregation_params
      params.require(:impl_aggregation).permit(:core_project_id, :genre, :name, :wikiname, :created_by, :updated_by, :last_requested_at, :last_updated_at, :provider_ids)
    end
end
