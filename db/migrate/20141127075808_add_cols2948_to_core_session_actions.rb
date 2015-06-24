class AddCols2948ToCoreSessionActions < ActiveRecord::Migration
  def change
    add_column :core_session_actions, :message, :text
  end
end
