class AddColstoImplAggregations < ActiveRecord::Migration
  def change
    add_column :impl_aggregations, :properties, :hstore
  end
end
