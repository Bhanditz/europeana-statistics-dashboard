class AddColstoImplAggregation < ActiveRecord::Migration
  def change
    add_column :impl_aggregations, :status, :string
    add_column :impl_aggregations, :error_messages,:string
  end
end
