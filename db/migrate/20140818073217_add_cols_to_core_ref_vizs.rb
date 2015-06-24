class AddColsToCoreRefVizs < ActiveRecord::Migration
  def change
    add_column :core_ref_vizs, :pykcharts_name, :string
  end
end
