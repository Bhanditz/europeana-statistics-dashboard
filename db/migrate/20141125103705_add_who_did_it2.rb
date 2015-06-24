class AddWhoDidIt2 < ActiveRecord::Migration
  def change
    add_column :core_authentications, :created_by, :integer
    add_column :core_authentications, :updated_by, :integer
    
    add_column :core_configuration_editors, :created_by, :integer
    add_column :core_configuration_editors, :updated_by, :integer
    
    add_column :core_data_stores, :created_by, :integer
    add_column :core_data_stores, :updated_by, :integer
    
    add_column :core_permissions, :created_by, :integer
    add_column :core_permissions, :updated_by, :integer
    
    add_column :core_vizs, :created_by, :integer
    add_column :core_vizs, :updated_by, :integer
    
    add_column :ref_charts, :created_by, :integer
    add_column :ref_charts, :updated_by, :integer
  end
end
