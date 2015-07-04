class RenameTableCoreDataStorePullToCoreDatacastPull < ActiveRecord::Migration
  def change
    rename_table :core_data_store_pulls, :core_datacast_pulls
      add_column :core_datacast_pulls, :core_db_connection_id, :integer
      add_column :core_datacast_pulls, :table_name, :string 
  end
end
