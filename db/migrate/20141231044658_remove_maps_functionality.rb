class RemoveMapsFunctionality < ActiveRecord::Migration
  def change
    drop_table :core_maps
    drop_table :core_map_pins
    drop_table :core_map_columns
  end
end
