class CreateCoreMapsVizs22 < ActiveRecord::Migration
  def change
    create_table :core_map_vizs do |t|
      t.integer :core_map_id
      t.integer :core_viz_id
      t.string :name
      t.integer :core_tooltip_viz_id
      t.string :genre
      t.hstore :properties
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
