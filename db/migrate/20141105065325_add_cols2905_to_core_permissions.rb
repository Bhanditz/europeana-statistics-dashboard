class AddCols2905ToCorePermissions < ActiveRecord::Migration
  def change
    add_column :core_permissions, :genre, :string
  end
end
