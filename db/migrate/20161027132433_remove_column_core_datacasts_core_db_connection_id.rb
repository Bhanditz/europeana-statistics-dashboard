# frozen_string_literal: true
class RemoveColumnCoreDatacastsCoreDbConnectionId < ActiveRecord::Migration
  def change
    remove_column :core_datacasts, :core_db_connection_id, :integer
  end
end
