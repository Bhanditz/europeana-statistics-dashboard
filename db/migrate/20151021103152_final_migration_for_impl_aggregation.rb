class FinalMigrationForImplAggregation < ActiveRecord::Migration
  def change
    Impl::Aggregation.destroy_all
    Core::Datacast.destroy_all
    Impl::Output.destroy_all
    Core::TimeAggregation.destroy_all
    execute " Drop view impl_aggregation_ranks; Drop view impl_aggregation_rank_of_pageviews; Drop view impl_aggregation_rank_of_collections;"

    drop_table :impl_aggregation_providers
    remove_column :impl_aggregations, :wikiname
    remove_column :impl_aggregations, :last_requested_at
    remove_column :impl_aggregations, :last_updated_at
    remove_column :impl_aggregations, :country

    create_table :impl_aggregation_relations do |t|
      t.integer :impl_parent_id
      t.string :impl_parent_genre
      t.integer :impl_child_id
      t.string  :impl_child_genre
      t.timestamps null: false
    end

    rename_table :impl_providers, :impl_datasets
    rename_column :impl_datasets, :provider_id, :data_set_id
    add_column :impl_datasets, :impl_aggregation_id, :integer
    add_column :impl_datasets, :name, :string

  end
end
