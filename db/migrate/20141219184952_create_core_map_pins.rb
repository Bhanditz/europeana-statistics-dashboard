class CreateCoreMapPins < ActiveRecord::Migration
  def change
    create_table :core_map_pins do |t|
      t.integer :core_map_id
      t.integer :core_data_store_id
      t.string :column_name
      t.string :value
      t.text :img
      t.boolean :is_other
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
