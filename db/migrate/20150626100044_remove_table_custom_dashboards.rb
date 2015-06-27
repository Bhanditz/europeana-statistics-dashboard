class RemoveTableCustomDashboards < ActiveRecord::Migration
  def change
    drop_table :core_custom_dashboards
  end
end
