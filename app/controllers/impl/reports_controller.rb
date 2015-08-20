class Impl::ReportsController < ApplicationController
  #include Europeana::Styleguide

  before_action :sudo_public!, only: [:show]
  before_action :set_impl_report, only: [:show]


  def show
  	selected_date = Date.today.at_beginning_of_month - 1
    gon.selected_year = selected_date.year
    gon.selected_quarter = ((selected_date.month.to_i - 1)/3) + 1
  end

  private

  def set_impl_report
    @impl_report = Impl::Report.friendly.find(params[:impl_report_id])
  end

end
