class CreateImplAggregations < ActiveRecord::Migration
  def change
    create_table :impl_aggregations do |t|
      t.integer :core_project_id
      t.string :genre
      t.string :name
      t.string :wikiname
      t.integer :created_by
      t.integer :updated_by
      t.integer :last_requested_at
      t.integer :last_updated_at

      t.timestamps null: false
    end
    create_table :impl_providers do |t|
      t.integer :impl_aggregation_id
      t.string :provider_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
