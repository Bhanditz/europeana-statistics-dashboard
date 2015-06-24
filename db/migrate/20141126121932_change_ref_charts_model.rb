class ChangeRefChartsModel < ActiveRecord::Migration
  def change
    #rename column name
    rename_column :ref_charts, :image, :img_small
    rename_column :ref_charts, :interface, :api
    #remove columns
    remove_column :ref_charts, :js_files_to_include
    remove_column :ref_charts, :css_files_to_include
    remove_column :ref_charts, :config
    #add new columns
    add_column :ref_charts, :img_data_mapping, :string
    add_column :ref_charts, :slug, :string
    add_column :ref_charts, :combination_code, :string, limit: 6
    add_column :ref_charts, :source, :string
    add_column :ref_charts, :file_path, :string
    add_column :ref_charts, :sort_order, :integer
  end
end 