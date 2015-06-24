class CreateCoreTeamProjects < ActiveRecord::Migration
  def change
    create_table :core_team_projects do |t|
      t.integer :core_team_id
      t.integer :core_project_id
      t.string :role
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
