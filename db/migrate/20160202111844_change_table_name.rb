# frozen_string_literal: true
class ChangeTableName < ActiveRecord::Migration
  def change
    rename_table :impl_data_provider_data_sets, :impl_aggregation_data_sets
    execute('ALTER INDEX impl_data_provider_data_sets_index RENAME TO impl_aggregation_data_sets_index')
  end
end
