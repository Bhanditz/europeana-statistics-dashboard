class CreateCoreCardLayouts < ActiveRecord::Migration
  def change
    create_table :core_card_layouts do |t|
      t.string :name
      t.text :template
      t.text :img
      t.integer :sort_order

      t.timestamps null: false
    end
  end
end
