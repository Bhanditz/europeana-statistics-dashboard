class CreateTableCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.string :name
      t.text :description
      t.text :image
      t.string :genre
      t.text :map
      t.text :interface
      t.text :js_files_to_include
      t.text :css_files_to_include
    end
  end
end
