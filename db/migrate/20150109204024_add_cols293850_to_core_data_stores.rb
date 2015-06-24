class AddCols293850ToCoreDataStores < ActiveRecord::Migration
  def change
    add_column :core_data_stores, :join_query, :json
  end
end
