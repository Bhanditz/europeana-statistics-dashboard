class CreateCoreAccountImages < ActiveRecord::Migration
  def change
    create_table :core_account_images do |t|
      t.integer :account_id
      t.string :filetype
      t.text :image_url
      t.string :filesize
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
