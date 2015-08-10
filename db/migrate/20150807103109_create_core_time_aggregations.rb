class CreateCoreTimeAggregations < ActiveRecord::Migration
  def change
    create_table :core_time_aggregations do |t|
      t.string :aggregation_level
      t.string :parent_type
      t.integer :parent_id
      t.string :aggregation_level_value
      t.string :metric
      t.integer :value
      t.integer :difference_from_previous_value
      t.boolean :is_positive_value

      t.timestamps null: false
    end

    create_table :impl_static_attributes do |t|
      t.integer :impl_output_id
      t.string :key
      t.string :value

      t.timestamps null: false
    end

    remove_column :impl_outputs, :output
    add_column :impl_outputs, :key, :string
    add_column :impl_outputs, :value, :string
  end
end
