class AddMoreColsToCoreTimeAggregation < ActiveRecord::Migration
  def change
    add_column :core_time_aggregations, :aggregation_value_to_display, :string
  end
end
