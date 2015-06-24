class CreateCoreThemes < ActiveRecord::Migration
  def change
    create_table :core_themes do |t|
      t.integer :account_id
      t.string :name
      t.integer :sort_order
      t.hstore :config
      t.text :image_url
      t.boolean :is_admin_theme
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
