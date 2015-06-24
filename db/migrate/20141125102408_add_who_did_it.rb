class AddWhoDidIt < ActiveRecord::Migration
  def change
    add_column :core_projects, :created_by, :integer
    add_column :core_projects, :updated_by, :integer
  end
end
