class AddVizIDtoSessionsImpl < ActiveRecord::Migration
  def change
    add_column :core_session_impls, :core_viz_id, :integer
  end
end
