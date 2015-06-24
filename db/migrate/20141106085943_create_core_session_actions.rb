class CreateCoreSessionActions < ActiveRecord::Migration
  def change
    create_table :core_session_actions do |t|
      t.integer :account_id
      t.integer :core_session_impl_id
      t.string :genre
      t.integer :organistion_id
      t.integer :project_id
      t.string :objectable_type
      t.integer :objectable_id

      t.timestamps
    end
  end
end
