class ChangeColsInCoreViz < ActiveRecord::Migration
  def change
    add_column :core_vizs, :core_datacast_identifier, :string
    add_column :core_vizs, :filter_present, :boolean
    remove_column :core_vizs, :refresh_freq_in_minutes
    remove_column :core_vizs, :output
    remove_column :core_vizs, :refreshed_at
    remove_column :core_vizs, :datagram_identifier
    remove_column :core_vizs, :is_static
    remove_column :core_vizs, :was_output_big
    remove_column :core_vizs, :pykquery_object
  end
end
