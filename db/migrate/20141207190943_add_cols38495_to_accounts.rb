class AddCols38495ToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :confirmation_sent_at, :datetime
    add_column :accounts, :reset_password_sent_at, :datetime
  end
end
