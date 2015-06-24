class CreateCoreMaps < ActiveRecord::Migration
  def change
    create_table :core_maps do |t|
      t.integer :core_project_id
      t.string :name
      t.string :slug
      t.hstore :properties
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
