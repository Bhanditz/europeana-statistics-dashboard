class AddDescriptionToDataStores < ActiveRecord::Migration
  def change
    add_column :core_data_stores, :meta_description, :text
  end
end
