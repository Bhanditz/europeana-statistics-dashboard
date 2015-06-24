class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.string :code
      t.string :genre
      t.string :decode
      t.integer :parent_id
      t.text :synonyms
      t.text :wikipedia
      t.boolean :is_approved
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    
    add_index :dictionaries, :code
    add_index :dictionaries, :genre
    add_index :dictionaries, :decode
    add_index :dictionaries, :parent_id
    
  end
end
