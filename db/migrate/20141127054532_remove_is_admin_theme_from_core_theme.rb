class RemoveIsAdminThemeFromCoreTheme < ActiveRecord::Migration
  def change
    remove_column :core_themes, :is_admin_theme
  end
end
