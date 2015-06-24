class ChangeColumnTypeProperties < ActiveRecord::Migration
  def change
    remove_column :core_project_oauths, :properties
    add_column :core_project_oauths, :properties, :json
  end
end
