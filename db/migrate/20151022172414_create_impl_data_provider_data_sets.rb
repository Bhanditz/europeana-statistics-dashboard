class CreateImplDataProviderDataSets < ActiveRecord::Migration
  def change
    create_table :impl_data_provider_data_sets do |t|
      t.integer :impl_aggregation_id
      t.integer :impl_data_set_id

      t.timestamps null: false
    end
  end
end
