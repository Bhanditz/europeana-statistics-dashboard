class DestroyUselessMapObjects < ActiveRecord::Migration
  def change
    drop_table :core_map_data_stores
    drop_table :core_map_dispersions
  end
end
