class CreateCoreArticles < ActiveRecord::Migration
  def change
    create_table :core_articles do |t|
      t.integer :core_project_id
      t.string :name
      t.integer :created_by
      t.integer :updated_by
      t.string :status

      t.timestamps null: false
    end
  end
end
