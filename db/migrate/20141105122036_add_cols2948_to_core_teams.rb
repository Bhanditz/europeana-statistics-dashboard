class AddCols2948ToCoreTeams < ActiveRecord::Migration
  def change
    add_column :core_teams, :is_owner_team, :boolean
  end
end
