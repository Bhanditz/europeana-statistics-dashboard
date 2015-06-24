class AddTableNameToDataStores < ActiveRecord::Migration
  def change
    add_column :data_stores, :table_name, :string
  end
end
