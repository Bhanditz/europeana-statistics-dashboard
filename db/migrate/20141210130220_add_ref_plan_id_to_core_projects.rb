class AddRefPlanIdToCoreProjects < ActiveRecord::Migration
  def change
    add_column :core_projects, :ref_plan_slug, :string
  end
end
