class CleaningUpUnwantedTables < ActiveRecord::Migration
  def change
    drop_table :core_articles
    drop_table :core_article_cards
    drop_table :core_cards
    drop_table :core_card_layouts
  end
end