class RemoveUnwantedTables < ActiveRecord::Migration
  def change
    drop_table :core_metadata_attachments
    drop_table :core_metadata_data_store_columns
    #drop_table :core_metadata_dates
    drop_table :core_metadata_locations
    drop_table :core_metadata_tags
    drop_table :core_nlp_dictionaries
    drop_table :core_nlp_master_dictionaries
    drop_table :dictionaries
    drop_table :social_messages
    drop_table :social_profiles
  end
end
