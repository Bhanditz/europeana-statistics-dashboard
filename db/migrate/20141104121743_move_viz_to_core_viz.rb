class MoveVizToCoreViz < ActiveRecord::Migration
  def change
    rename_table :vizs, :core_vizs
  end
end
