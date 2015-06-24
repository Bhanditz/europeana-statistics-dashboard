class RemoveDatastore < ActiveRecord::Migration
  def change
    remove_column :data_stores, :content
    remove_column :data_stores, :content_text
  end
end
