class CreateCoreMapColumns < ActiveRecord::Migration
  def change
    create_table :core_map_columns do |t|
      t.integer :core_map_id
      t.integer :core_data_store_id
      t.string :column_name
      t.integer :sort_order
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
