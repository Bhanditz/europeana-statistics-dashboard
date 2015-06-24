class AddIsOwnerTeamToCorePermissions < ActiveRecord::Migration
  def change
    add_column :core_permissions, :is_owner_team, :boolean
  end
end
