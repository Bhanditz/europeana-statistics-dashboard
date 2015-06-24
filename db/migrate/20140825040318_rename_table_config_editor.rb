class RenameTableConfigEditor < ActiveRecord::Migration
  def change
    rename_table :core_util_config_editors, :configuration_editors
  end
end
