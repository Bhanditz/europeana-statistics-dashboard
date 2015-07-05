class CreateCoreArticleCards < ActiveRecord::Migration
  def change
    create_table :core_article_cards do |t|
      t.integer :core_article_id
      t.integer :core_card_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
