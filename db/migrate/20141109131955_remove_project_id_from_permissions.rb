class RemoveProjectIdFromPermissions < ActiveRecord::Migration
  def change
    remove_column :core_permissions, :core_project_id
    remove_column :core_teams, :core_user_project_id
  end
end
