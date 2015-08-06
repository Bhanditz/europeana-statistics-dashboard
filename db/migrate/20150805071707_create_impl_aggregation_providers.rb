class CreateImplAggregationProviders < ActiveRecord::Migration
  def change
    create_table :impl_aggregation_providers do |t|
      t.integer :impl_aggregation_id
      t.integer :impl_provider_id
      t.timestamps null: false
    end
  end
end
