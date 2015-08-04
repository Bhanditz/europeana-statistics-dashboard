class CreateImplAggregationOutputs < ActiveRecord::Migration
  def change
    create_table :impl_aggregation_outputs do |t|
      t.integer :impl_aggregation_id
      t.text :output
      t.string :fingerprint
      t.timestamps null: false
    end

    add_column :impl_aggregations, :status, :string
    add_column :impl_aggregations, :error_messages, :string
  end
end
