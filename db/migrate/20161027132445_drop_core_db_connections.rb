# frozen_string_literal: true
class DropCoreDbConnections < ActiveRecord::Migration
  def change
    drop_table :core_db_connections
  end
end
