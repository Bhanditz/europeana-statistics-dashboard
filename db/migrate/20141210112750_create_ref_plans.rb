class CreateRefPlans < ActiveRecord::Migration
  def change
    create_table :ref_plans do |t|
      t.string :name
      t.string :slug
      t.hstore :properties
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
