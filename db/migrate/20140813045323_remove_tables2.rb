class RemoveTables2 < ActiveRecord::Migration
  def change
    drop_table :versions
    drop_table :core_util_activities
  end
end
