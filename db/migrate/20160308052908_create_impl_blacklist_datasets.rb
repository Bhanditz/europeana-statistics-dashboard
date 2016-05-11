class CreateImplBlacklistDatasets < ActiveRecord::Migration
  def change
    create_table :impl_blacklist_datasets do |t|
      t.string :dataset

      t.timestamps null: false
    end
  end
end
