class AddCols2849ToCoreTeams < ActiveRecord::Migration
  def change
    add_column :core_teams, :core_user_project_id, :integer
  end
end
