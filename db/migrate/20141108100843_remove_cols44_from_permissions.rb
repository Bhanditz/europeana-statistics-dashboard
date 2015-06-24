class RemoveCols44FromPermissions < ActiveRecord::Migration
  def change
    remove_column :core_permissions, :genre
  end
end
