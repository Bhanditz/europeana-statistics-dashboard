class RemoveDataStores < ActiveRecord::Migration
  def change
    drop_table :core_data_stores
    remove_column :core_vizs, :core_data_store_id
  end
end
