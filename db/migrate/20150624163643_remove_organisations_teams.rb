class RemoveOrganisationsTeams < ActiveRecord::Migration
  def change
    drop_table :core_teams
    drop_table :core_team_projects
    remove_column :accounts, :accountable_type
    remove_column :core_permissions, :core_team_id
    remove_column :core_permissions, :organisation_id
    add_column :core_permissions, :core_project_id, :integer
  end
end
