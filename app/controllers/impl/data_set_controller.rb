class Impl::DataSetsController < ApplicationController
  
  before_action :sudo_project_member!, :set_impl_aggregation
  before_action :set_impl_provider, only: [:restart_worker, :destroy]

  def index
    @impl_providers = @impl_aggregation.impl_providers
    @impl_provider = Impl::DataSet.new
  end

  def create
    @impl_provider = Impl::DataSet.new(impl_provider_params)
    @impl_provider.created_by = current_account.id
    @impl_provider.updated_by = current_account.id
    if @impl_provider.save
      redirect_to edit_account_project_impl_aggregation_path(@core_project.account, @core_project, @impl_aggregation), notice: t("c.s")
    else
      @impl_providers = @impl_aggregation.impl_providers
      render :index
    end
  end

  def destroy
    @impl_provider.destroy
    redirect_to account_project_impl_aggregation_providers_path(@core_project.account, @core_project, @impl_aggregation), notice: t("d.s")
  end

  def restart_worker
    Core::TimeAggregation.where(parent_id: @impl_provider.impl_provider_outputs.pluck(:id)).delete_all
    Impl::TrafficBuilder.perform_async(@impl_provider.id)
    redirect_to :back, notice: t("provider.worker")
  end
  
  private

  def set_impl_aggregation
    @impl_aggregation = Impl::Aggregation.find(h params[:aggregation_id])
  end

  def set_impl_provider
    @impl_provider = Impl::DataSet.find("#{h params[:id]}")
  end

  def impl_provider_params
    params.require(:impl_provider).permit(:data_set_id, :created_by, :updated_by)
  end
  
end
