# frozen_string_literal: true
class Impl::BlacklistDatasetsController < ApplicationController
  before_action :authenticate_account!

  # Overview of all Black listed datasets.
  def index
    @blacklist_datasets = Impl::BlacklistDataset.order(created_at: :desc).page(params[:page]).per(30)
    @blacklist_dataset = Impl::BlacklistDataset.new
  end

  # Creates a new blacklist entry in the database and caches all the blacklisted datasets.
  def create
    @blacklist_dataset = Impl::BlacklistDataset.new(blacklist_dataset_params)
    if @blacklist_dataset.save
      Rails.cache.fetch('blacklist_datasets') { Impl::BlacklistDataset.all.pluck(:dataset) }
      redirect_to :back, notice: t('c.s')
    else
      @blacklist_datasets = Impl::BlacklistDataset.all
      render :index
    end
  end

  # Destroies a particular blacklist entry in the database and caches all the blacklisted datasets.
  def destroy
    @blacklist_dataset = Impl::BlacklistDataset.find(params[:id])
    @blacklist_dataset.destroy
    Rails.cache.fetch('blacklist_datasets') { Impl::BlacklistDataset.all.pluck(:dataset) }
    redirect_to :back, notice: t('d.s')
  end

  private

  def blacklist_dataset_params
    params.require(:impl_blacklist_dataset).permit(:dataset)
  end
end
