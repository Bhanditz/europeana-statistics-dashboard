class CreateCoreMapDashboards < ActiveRecord::Migration
  def change
    create_table :core_maps do |t|
      t.integer :core_project_id
      t.string :name
      t.string :slug
      t.integer :core_data_store_id
      t.hstore :properties
      t.json :theme
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
