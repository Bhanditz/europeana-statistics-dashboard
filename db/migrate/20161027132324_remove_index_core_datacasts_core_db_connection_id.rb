# frozen_string_literal: true
class RemoveIndexCoreDatacastsCoreDbConnectionId < ActiveRecord::Migration
  def up
    remove_index 'core_datacasts', name: 'core_datacasts_core_db_connection_id'
  end
  def down
    add_index 'core_datacasts', ['core_db_connection_id'], name: 'core_datacasts_core_db_connection_id'
  end
end
