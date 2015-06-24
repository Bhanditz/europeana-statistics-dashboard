class AddPropertiesToAccountImages < ActiveRecord::Migration
  def change
    add_column :core_account_images, :properties, :hstore
  end
end
