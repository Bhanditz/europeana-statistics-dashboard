class AddSlugtoCoreDatacast < ActiveRecord::Migration
  def change
    add_column :core_datacasts, :slug, :string
    add_column :core_datacasts,:table_name, :string
    Core::Datacast.find_each(&:save)
  end
end
