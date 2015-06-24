class CreateCoreMapDataStores < ActiveRecord::Migration
  def change
    create_table :core_map_data_stores do |t|
      t.integer :core_map_id
      t.integer :core_data_store_id
      t.string :latitude
      t.string :longitude
      t.string :cluster
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
