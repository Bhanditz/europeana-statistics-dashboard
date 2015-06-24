class AddColumnCoreMapFileIdToCoreSessionImpls < ActiveRecord::Migration
  def change
    add_column :core_session_impls, :core_map_file_id, :integer
  end
end
