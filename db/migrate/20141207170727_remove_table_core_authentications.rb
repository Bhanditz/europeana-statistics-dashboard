class RemoveTableCoreAuthentications < ActiveRecord::Migration
  def change
    drop_table :core_authentications
  end
end
