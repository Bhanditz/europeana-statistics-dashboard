class CreateCoreTemplates < ActiveRecord::Migration
  def change
    create_table :core_templates do |t|
      t.string :name
      t.text :html_content
      t.string :genre
      t.json :required_variables

      t.timestamps null: false
    end

    create_table :impl_reports do |t|
      t.integer :impl_aggregation_id
      t.integer :core_template_id
      t.string :name
      t.string :slug
      t.text :html_content
      t.json :variable_object

      t.timestamps null: false
    end
  end
end