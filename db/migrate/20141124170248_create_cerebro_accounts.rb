class CreateCerebroAccounts < ActiveRecord::Migration
  def change
    create_table :cerebro_accounts do |t|
      t.string :email
      t.integer :account_id
      t.hstore :properties
      t.json :response
      t.datetime :request_sent_at
      t.string :status

      t.timestamps
    end
    create_table :cerebro_socials do |t|
      t.integer :cerebro_account_id
      t.string :source
      t.string :source_name
      t.text :photo_url
      t.text :bio
      t.text :url
      t.string :identifier
      t.string :username
      t.string :followers
      t.string :following

      t.timestamps
    end
    create_table :cerebro_works do |t|
      t.integer :cerebro_account_id
      t.string :start_date
      t.string :end_date
      t.string :title
      t.string :is_primary
      t.string :name
      t.string :is_current

      t.timestamps
    end
    create_table :cerebro_websites do |t|
      t.integer :cerebro_account_id
      t.text :url
      t.string :genre
      t.string :handle
      t.string :client
      t.timestamps
    end
  end
end
