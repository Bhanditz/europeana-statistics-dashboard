class AddCols839405ToCoreVizs < ActiveRecord::Migration
  def change
    add_column :core_vizs, :refresh_freq_in_minutes, :integer
    add_column :core_vizs, :output, :text
    add_column :core_vizs, :refreshed_at, :datetime
    add_column :core_vizs, :datagram_identifier, :string
    add_column :core_vizs, :is_static, :boolean
    add_column :core_vizs, :was_output_big, :boolean
    add_index "core_vizs", ["datagram_identifier"], name: "index_core_vizs_on_datagram_identifier", using: :btree
  end
end
