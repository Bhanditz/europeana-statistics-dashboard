class Impl::AggregationsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_impl_aggregation, only: [:show, :edit, :update, :destroy]

  def index
    @impl_aggregations = @core_project.impl_aggregations
    @impl_aggregation = Impl::Aggregation.new
  end

  def create
    @impl_aggregation = Impl::Aggregation.new(impl_aggregation_params)
    @impl_aggregation.created_by = current_account.id
    @impl_aggregation.updated_by = current_account.id
    if @impl_aggregation.save
      redirect_to account_project_impl_aggregations_path(@core_project.account, @core_project), notice: 'Impl aggregation was successfully created.'
    else
      render :index
    end
  end

  def update
    @impl_aggregation.updated_by = current_account.id
    if @impl_aggregation.update(impl_aggregation_params)
      redirect_to account_project_impl_aggregation_providers_path(@core_project.account, @core_project, @impl_aggregation), notice: 'Impl aggregation was successfully updated.'
    else
      render "impl/providers/index"
    end
  end

  def destroy
    @impl_aggregation.destroy
    redirect_to account_project_impl_aggregations_path(@core_project.account, @core_project), notice: 'Impl aggregation was successfully destroyed.'
  end

  private

    def set_impl_aggregation
      @impl_aggregation = Impl::Aggregation.find(params[:id])
    end

    def impl_aggregation_params
      params.require(:impl_aggregation).permit(:core_project_id, :genre, :name, :wikiname, :created_by, :updated_by, :last_requested_at, :last_updated_at)
    end
end
