class AddColumnsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :is_approved, :boolean
  end
end
