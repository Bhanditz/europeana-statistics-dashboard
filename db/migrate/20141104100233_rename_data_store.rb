class RenameDataStore < ActiveRecord::Migration
  def change
    rename_table :data_stores, :core_data_stores
    rename_column :vizs, :data_store_id, :core_data_store_id
  end
end
