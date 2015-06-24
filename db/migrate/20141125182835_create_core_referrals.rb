class CreateCoreReferrals < ActiveRecord::Migration
  def change
    create_table :core_referrals do |t|
      t.string :email
      t.integer :account_id
      t.integer :referered_id
      t.boolean :is_eligible
      t.text :notes
      t.integer :created_by
      t.integer :updated_by 

      t.timestamps
    end
  end
end
