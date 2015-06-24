class Removemaps < ActiveRecord::Migration
  def change
    drop_table :core_maps
    drop_table :core_map_vizs
  end
end
