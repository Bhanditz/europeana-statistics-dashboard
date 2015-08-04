class CreateImplProviderOutputs < ActiveRecord::Migration
  def change
    create_table :impl_provider_outputs do |t|
      t.integer :impl_provider_id
      t.text :output
      t.string :social_type
      t.string :fingerprint
      t.timestamps null: false
    end

    add_column :impl_providers, :status, :string
    add_column :impl_providers, :error_messages, :string
  end
end