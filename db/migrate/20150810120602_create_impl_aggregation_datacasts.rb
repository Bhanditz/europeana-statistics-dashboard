class CreateImplAggregationDatacasts < ActiveRecord::Migration
  def change
    create_table :impl_aggregation_datacasts do |t|
      t.integer :impl_aggregation_id
      t.string :core_datacast_identifier

      t.timestamps null: false
    end
  end
end
