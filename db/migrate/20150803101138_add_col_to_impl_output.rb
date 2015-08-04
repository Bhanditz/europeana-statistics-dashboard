class AddColToImplOutput < ActiveRecord::Migration
  def change
    add_column :impl_outputs, :status, :string
    add_column :impl_outputs, :error_messages, :string
    remove_column :impl_outputs, :fingerprint
  end
end
