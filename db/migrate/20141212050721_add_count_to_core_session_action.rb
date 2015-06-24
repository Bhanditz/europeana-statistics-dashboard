class AddCountToCoreSessionAction < ActiveRecord::Migration
  def change
    add_column :core_session_actions, :count, :integer
    rename_column :core_session_actions, :organistion_id, :organisation_id
  end
end
