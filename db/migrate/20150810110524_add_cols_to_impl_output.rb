class AddColsToImplOutput < ActiveRecord::Migration
  def change
    add_column :impl_outputs, :properties, :hstore
  end
end
