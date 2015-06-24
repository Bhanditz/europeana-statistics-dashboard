class CreateCoreCustomDashboards < ActiveRecord::Migration
  def change
    create_table :core_custom_dashboards do |t|
      t.integer :core_project_id
      t.string :name
      t.hstore :properties
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
