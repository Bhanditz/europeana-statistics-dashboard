class RemoveTables < ActiveRecord::Migration
  def change
    drop_table :app_data_timeseries
    drop_table :social_mentions
  end
end
