class ChangeDataTypeOfFileUrl < ActiveRecord::Migration
  def change
    change_column :core_data_store_pulls, :file_url, :text
    rename_column :core_data_store_pulls, :project_id, :core_project_id
  end
end
