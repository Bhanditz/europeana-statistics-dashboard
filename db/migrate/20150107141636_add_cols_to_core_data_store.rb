class AddColsToCoreDataStore < ActiveRecord::Migration
  def change
    add_column :core_data_stores, :genre_class, :string
    add_column :core_data_stores, :is_verified_dictionary, :boolean
  end
end
