class CreateCoreDatacastOutputs < ActiveRecord::Migration
  def change
    add_column :core_datacasts, :last_run_at, :datetime
    add_column :core_datacasts, :last_data_changed_at, :datetime
    add_column :core_datacasts, :count_of_queries, :integer
    add_column :core_datacasts, :average_execution_time, :float
    add_column :core_datacasts, :size, :float
    create_table :core_datacast_outputs do |t|
      t.string :datacast_identifier, null: false, unique: true
      t.integer :core_datacast_id, null: false
      t.text :output
      t.text :fingerprint

      t.timestamps null: false
    end
    add_index "core_datacast_outputs", ["datacast_identifier"], name: "index_core_datacast_outputs_on_datacast_identifier", unique: true, using: :btree
  end
end
