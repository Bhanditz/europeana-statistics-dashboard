class DropImplAggregationOutput < ActiveRecord::Migration
  def change
    drop_table :impl_aggregation_outputs
    rename_table :impl_provider_outputs, :impl_outputs
    add_column :impl_outputs, :impl_parent_type, :string
    add_column :impl_outputs, :impl_parent_id, :integer
    remove_column :impl_outputs, :impl_provider_id
  end
end