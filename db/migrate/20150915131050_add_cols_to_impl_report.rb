class AddColsToImplReport < ActiveRecord::Migration
  def change
    add_column :impl_reports, :core_project_id, :integer, default: 1
  end
end
