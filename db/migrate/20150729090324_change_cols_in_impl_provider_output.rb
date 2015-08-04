class ChangeColsInImplProviderOutput < ActiveRecord::Migration
  def change
    rename_column :impl_provider_outputs, :social_type, :genre
  end
end
