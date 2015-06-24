class AddIndexToCoreTokens < ActiveRecord::Migration
  def change
    add_index :core_tokens, :api_token  
  end
end
