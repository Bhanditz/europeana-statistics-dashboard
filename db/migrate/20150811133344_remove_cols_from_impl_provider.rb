class RemoveColsFromImplProvider < ActiveRecord::Migration
  def change
    remove_column :impl_providers, :impl_aggregation_id
  end
end
