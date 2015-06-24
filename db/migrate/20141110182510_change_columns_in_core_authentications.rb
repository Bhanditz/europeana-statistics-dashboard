class ChangeColumnsInCoreAuthentications < ActiveRecord::Migration
  def change
    add_column :core_authentications, :authenticable_type, :string
    add_column :core_authentications, :authenticable_id, :integer
    remove_column :core_authentications, :core_project_id
  end
end
