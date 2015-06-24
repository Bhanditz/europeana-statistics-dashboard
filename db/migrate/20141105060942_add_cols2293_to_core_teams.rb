class AddCols2293ToCoreTeams < ActiveRecord::Migration
  def change
    add_column :core_teams, :role, :string
    remove_column :core_team_projects, :role
  end
end
