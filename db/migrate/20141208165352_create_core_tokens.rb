class CreateCoreTokens < ActiveRecord::Migration
  def change
    create_table :core_tokens do |t|
      t.integer :account_id
      t.integer :core_project_id
      t.string :api_token
      t.string :name

      t.timestamps
    end
  end
end
