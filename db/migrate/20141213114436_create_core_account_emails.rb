class CreateCoreAccountEmails < ActiveRecord::Migration
  def change
    create_table :core_account_emails do |t|
      t.integer :account_id
      t.string :email
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.boolean :is_primary
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end
end
