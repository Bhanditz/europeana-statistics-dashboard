class RemoveAuthentication < ActiveRecord::Migration
  def change
    remove_column :core_data_stores, :core_authentication_id
    remove_column :core_projects, :cdn_core_authentication_id
  end
end
