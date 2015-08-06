class RemoveColsFromImplAggregation < ActiveRecord::Migration
  def change
    remove_column :impl_aggregations, :provider_ids
  end
end
