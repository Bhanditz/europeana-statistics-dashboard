class AddColPropertiesToCoreDatacast < ActiveRecord::Migration
  def change
    add_column :core_datacasts, :column_properties, :json, default: {}
  end
end