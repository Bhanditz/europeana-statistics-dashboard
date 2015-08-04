class AddColsToImplAggregationProvider < ActiveRecord::Migration
  def change
    add_column :impl_aggregations, :provider_ids, :string, array: true, default: []
  end
end