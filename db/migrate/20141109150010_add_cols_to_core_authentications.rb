class AddColsToCoreAuthentications < ActiveRecord::Migration
  def change
    add_column :core_authentications, :core_project_id, :integer
    remove_column :core_authentications, :account_id
  end
end
