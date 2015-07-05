class CreateCoreCards < ActiveRecord::Migration
  def change
    create_table :core_cards do |t|
      t.string :name
      t.boolean :is_public
      t.text :content
      t.hstore :properties
      t.integer :core_card_layout_id
      t.integer :core_project_id
      t.integer :core_datacast_identifier
      t.text    :image
      t.integer :created_by
      t.integer :updated_by
      t.integer :filesize

      t.timestamps null: false
    end
  end
end
