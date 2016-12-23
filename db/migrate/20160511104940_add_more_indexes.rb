# frozen_string_literal: true
class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index 'core_datacasts', ['core_project_id'], name: 'core_datacasts_core_project_id'
    add_index 'core_datacasts', ['core_db_connection_id'], name: 'core_datacasts_core_db_connection_id'

    add_index 'core_db_connections', ['core_project_id'], name: 'core_db_connections_core_project_id'

    add_index 'core_permissions', ['account_id'], name: 'core_permissions_account_id'
    add_index 'core_permissions', ['core_project_id'], name: 'core_permissions_core_project_id'

    add_index 'core_projects', ['account_id'], name: 'core_projects_account_id'

    add_index 'core_session_impls', ['core_viz_id'], name: 'core_session_impls_core_viz_id'

    add_index 'core_themes', ['account_id'], name: 'core_themes_account_id'

    add_index 'core_vizs', ['core_project_id'], name: 'core_vizs_core_project_id'

    add_index 'impl_aggregations', ['core_project_id'], name: 'impl_aggregations_core_project_id'

    add_index 'impl_reports', ['impl_aggregation_id'], name: 'impl_reports_impl_aggregation_id'
    add_index 'impl_reports', ['core_template_id'], name: 'impl_reports_core_template_id'
    add_index 'impl_reports', ['core_project_id'], name: 'impl_reports_core_project_id'
  end
end
