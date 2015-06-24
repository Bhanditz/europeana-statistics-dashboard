class AddSlugToCoreCustomDashboards < ActiveRecord::Migration
  def change
    add_column :core_custom_dashboards, :slug, :string
  end
end
