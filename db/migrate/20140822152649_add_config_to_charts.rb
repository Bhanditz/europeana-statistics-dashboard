class AddConfigToCharts < ActiveRecord::Migration
  def change
  	add_column :charts, :config, :json
  end
end
