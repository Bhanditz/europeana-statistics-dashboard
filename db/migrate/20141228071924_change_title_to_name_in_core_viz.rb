class ChangeTitleToNameInCoreViz < ActiveRecord::Migration
  def change
    rename_column :core_vizs, :title, :name 
  end
end
