# == Schema Information
#
# Table name: core_datacasts
#
#  id                     :integer          not null, primary key
#  core_project_id        :integer
#  core_db_connection_id  :integer
#  name                   :string
#  identifier             :string
#  properties             :hstore
#  created_by             :integer
#  updated_by             :integer
#  created_at             :datetime
#  updated_at             :datetime
#  params_object          :json             default({})
#  column_properties      :json             default({})
#  last_run_at            :datetime
#  last_data_changed_at   :datetime
#  count_of_queries       :integer
#  average_execution_time :float
#  size                   :float
#  slug                   :string
#  table_name             :string
#

class Core::DatacastsController < ApplicationController

  before_action :authenticate_account!
  before_action :set_core_datacast, only: [:run_worker]

  # Invokes the sidekiq worker to fetch data for a particular datacast.
  def run_worker
    Core::Datacast::RunWorker.perform_async(@core_datacast.id)
    redirect_to :back, notice: t("datacast.run_worker")
  end

  private

  def set_core_datacast
    @core_datacast = @core_project.core_datacasts.friendly.find(params[:id])
  end
end
