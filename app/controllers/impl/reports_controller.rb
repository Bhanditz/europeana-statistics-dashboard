class Impl::ReportsController < ApplicationController

  before_action :sudo_public!, only: [:show]
  before_action :set_impl_report, only: [:show]


  def show
  end

  private

  def set_impl_report
    @impl_report = Impl::Report.friendly.find(params[:impl_report_id])
  end

end
