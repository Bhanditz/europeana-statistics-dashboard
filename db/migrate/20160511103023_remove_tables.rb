# frozen_string_literal: true
class RemoveTables < ActiveRecord::Migration
  def change
    drop_table :core_datacast_pulls
    drop_table :core_tokens
    remove_column :core_datacast_outputs, :core_datacast_id
  end
end
