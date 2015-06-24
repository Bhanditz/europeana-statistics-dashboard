class AddCols2293ToCorePermissions < ActiveRecord::Migration
  def change
    add_column :core_permissions, :core_team_id, :integer
  end
end
