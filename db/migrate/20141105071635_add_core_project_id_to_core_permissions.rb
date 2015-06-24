class AddCoreProjectIdToCorePermissions < ActiveRecord::Migration
  def change
    add_column :core_permissions, :core_project_id, :integer
  end
end
