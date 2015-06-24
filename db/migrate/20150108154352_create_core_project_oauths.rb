class CreateCoreProjectOauths < ActiveRecord::Migration
  def change
    create_table :core_project_oauths do |t|
      t.integer :core_project_id
      t.string :unique_id
      t.string :provider
      t.hstore :properties
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
