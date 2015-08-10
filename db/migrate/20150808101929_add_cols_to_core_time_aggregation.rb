class AddColsToCoreTimeAggregation < ActiveRecord::Migration
  def change
    add_column :core_time_aggregations, :aggregation_index, :integer
  end
end
