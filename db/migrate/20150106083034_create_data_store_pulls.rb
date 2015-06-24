class CreateDataStorePulls < ActiveRecord::Migration
  def change
    create_table :core_data_store_pulls do |t|
      t.integer :project_id
      t.string :file_url
      t.boolean :first_row_header
      t.string :status
      t.text :error_messages
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end
end
