class Impl::BlacklistDatasetsController < ApplicationController
	before_action :sudo_project_member!

	def index
		@blacklist_datasets = Impl::BlacklistDataset.order(created_at: :desc).page.per(30)
		@blacklist_dataset = Impl::BlacklistDataset.new
	end

	def create
		@blacklist_dataset = Impl::BlacklistDataset.new(blacklist_dataset_params)
		if @blacklist_dataset.save
			$redis.set("blacklist_datasets",Impl::BlacklistDataset.all.pluck(:dataset))
			redirect_to :back, notice: t("c.s")
		else
			@blacklist_datasets = Impl::BlacklistDataset.all
			render :index
		end
	end

	def destroy
		@blacklist_dataset = Impl::BlacklistDataset.find(params[:id])
		@blacklist_dataset.destroy
		redirect_to :back, notice: t("d.s")
	end

	private

	def blacklist_dataset_params
		params.require(:impl_blacklist_dataset).permit(:dataset)
	end

end