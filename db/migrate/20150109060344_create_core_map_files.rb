class CreateCoreMapFiles < ActiveRecord::Migration
  def change
    create_table :core_map_files do |t|
      t.integer :account_id
      t.boolean :is_public
      t.string :name
      t.string :size
      t.string :filetype
      t.hstore :properties
      t.boolean :is_verified
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
