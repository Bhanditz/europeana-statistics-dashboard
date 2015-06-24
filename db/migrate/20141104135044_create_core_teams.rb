class CreateCoreTeams < ActiveRecord::Migration
  def change
    create_table :core_teams do |t|
      t.integer :organisation_id
      t.string :name
      t.integer :created_by
      t.integer :updated_by
      t.text :description

      t.timestamps
    end
  end
end
