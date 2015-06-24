class AddColsToCoreTokens < ActiveRecord::Migration
  def change
    add_column :core_tokens, :created_by, :integer
    add_column :core_tokens, :updated_by, :integer
  end
end
