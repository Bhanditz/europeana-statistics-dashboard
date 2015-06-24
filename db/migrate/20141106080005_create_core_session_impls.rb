class CreateCoreSessionImpls < ActiveRecord::Migration
  def change
    create_table :core_session_impls do |t|
      t.string :session_id
      t.integer :account_id
      t.string :ip
      t.string :device
      t.string :browser
      t.text :blurb

      t.timestamps
    end
    
    add_index :core_session_impls, :session_id, :unique => true
    add_index :core_session_impls, :account_id
    
  end
end
