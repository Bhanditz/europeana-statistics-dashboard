class CreateCoreReferralGifts < ActiveRecord::Migration
  def change
    create_table :core_referral_gifts do |t|
      t.integer :account_id
      t.integer :project_id
      t.integer :referral_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
