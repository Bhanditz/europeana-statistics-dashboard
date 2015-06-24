class AddCloneIdToDataStores < ActiveRecord::Migration
  def change
    add_column :data_stores, :clone_parent_id, :integer
  end
end
