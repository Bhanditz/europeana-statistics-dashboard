class DeleteRefChartIdFromVizs < ActiveRecord::Migration
  def change
    remove_column :core_vizs, :ref_chart_id
    remove_column :core_vizs,:data
    rename_column :core_vizs, :map, :pykquery_object
    add_column    :core_vizs, :ref_chart_combination_code, :string
  end
end
