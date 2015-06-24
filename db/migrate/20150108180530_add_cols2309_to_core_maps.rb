class AddCols2309ToCoreMaps < ActiveRecord::Migration
  def change
    add_column :core_maps, :cluster_data_store_id, :integer
  end
end
