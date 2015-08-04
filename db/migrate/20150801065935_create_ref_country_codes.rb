class CreateRefCountryCodes < ActiveRecord::Migration
  def change
    create_table :ref_country_codes do |t|
      t.string :country
      t.string :code

      t.timestamps null: false
    end
  end
end
