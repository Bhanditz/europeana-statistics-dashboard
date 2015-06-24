class RemoveUnnecessaryColumns < ActiveRecord::Migration
  def change
    remove_column :data_stores, :core_query_id
    drop_table :core_connector_bpms
    drop_table :core_connector_queries
    rename_table :charts, :ref_charts
    #rename_table :core_connector_authentications, :core_authentications
    remove_column :accounts, :current_sign_in_ip
    remove_column :accounts, :last_sign_in_at
    remove_column :accounts, :last_sign_in_ip
    remove_column :accounts, :confirmed_at
    remove_column :accounts, :confirmation_sent_at
    remove_column :accounts, :current_sign_in_at
    remove_column :accounts, :sign_in_count
    remove_column :accounts, :remember_created_at
    remove_column :accounts, :reset_password_sent_at
    remove_column :accounts, :is_approved
    add_column  :accounts, :devis, :hstore
    add_column :accounts, :sign_in_count, :integer
    rename_column :permissions, :parent_id, :organisation_id
    rename_table :projects, :core_projects
    rename_table :configuration_editors, :core_configuration_editors
    rename_column :core_configuration_editors, :project_id, :core_project_id
    rename_column :data_stores, :project_id, :core_project_id
    rename_column :data_stores, :cdn_authentication_id, :core_authentication_id
    rename_column :vizs, :project_id, :core_project_id
    rename_column :vizs, :core_ref_viz_id, :ref_chart_id
    rename_table :permissions, :core_permissions
  end
end
  