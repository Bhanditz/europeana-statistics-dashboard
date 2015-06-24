class ChangeConfigInCoreThemes < ActiveRecord::Migration
  def change
    change_column :core_themes, :config, "json USING CAST(config AS json)"
  end
end
