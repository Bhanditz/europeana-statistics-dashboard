class CreateCoreMapDispersions < ActiveRecord::Migration
  def change
    create_table :core_map_dispersions do |t|
      t.string :name
      t.integer :core_map_id
      t.integer :core_data_store_id
      t.string :column_name
      t.boolean :is_heatmap
      t.boolean :is_circle
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
