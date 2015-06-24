class AddPropertiesToConfigEditor < ActiveRecord::Migration
  def change
    add_column :configuration_editors, :properties, :hstore
  end
end
