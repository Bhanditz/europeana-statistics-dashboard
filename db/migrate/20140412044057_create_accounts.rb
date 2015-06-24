class CreateAccounts < ActiveRecord::Migration
  def change
    
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    enable_extension "hstore"

    create_table "accounts", force: true do |t|
      t.string   "username"
      t.string   "email",                  default: "", null: false
      t.string   "slug"
      t.string   "accountable_type"
      t.hstore   "properties"
      t.string   "encrypted_password",     default: "", null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string   "unconfirmed_email"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "authentication_token"
    end

    add_index "accounts", ["authentication_token"], name: "index_accounts_on_authentication_token", unique: true, using: :btree
    add_index "accounts", ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true, using: :btree
    add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
    add_index "accounts", ["properties"], name: "accounts_properties", using: :gin
    add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
    add_index "accounts", ["slug"], name: "index_accounts_on_slug", unique: true, using: :btree
    add_index "accounts", ["username"], name: "index_accounts_on_username", unique: true, using: :btree

    create_table "app_data_timeseries", force: true do |t|
      t.datetime "published_at"
      t.string   "source"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id"
      t.integer  "project_id"
      t.integer  "core_connector_query_id"
      t.hstore   "properties"
    end

    create_table "core_authentications", force: true do |t|
      t.integer  "account_id"
      t.string   "provider"
      t.string   "official_identifier"
      t.string   "token"
      t.string   "secret"
      t.text     "response_object"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.hstore   "properties"
    end

    add_index "core_authentications", ["official_identifier"], name: "index_core_authentications_on_official_identifier", using: :btree

    create_table "core_connector_bpms", force: true do |t|
      t.integer  "project_id"
      t.integer  "account_id"
      t.string   "jib"
      t.string   "bpm_id"
      t.integer  "worker_id"
      t.integer  "next_id"
      t.string   "bpm_class"
      t.string   "worker_class"
      t.string   "status"
      t.datetime "start"
      t.datetime "end"
      t.float    "time_it_ran"
      t.boolean  "descendants_are_complete"
      t.text     "error"
      t.integer  "core_connector_query_id"
      t.integer  "data_store_id"
      t.datetime "enqueued_at"
      t.string   "queue"
      t.boolean  "retry"
      t.string   "name"
      t.text     "result"
      t.text     "backtrace"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "core_connector_bpms", ["account_id"], name: "index_core_connector_bpms_on_account_id", using: :btree
    add_index "core_connector_bpms", ["bpm_id"], name: "index_core_connector_bpms_on_bpm_id", using: :btree
    add_index "core_connector_bpms", ["core_connector_query_id"], name: "index_core_connector_bpms_on_core_connector_query_id", using: :btree
    add_index "core_connector_bpms", ["data_store_id"], name: "index_core_connector_bpms_on_data_store_id", using: :btree
    add_index "core_connector_bpms", ["jib"], name: "index_core_connector_bpms_on_jib", using: :btree
    add_index "core_connector_bpms", ["project_id"], name: "index_core_connector_bpms_on_project_id", using: :btree

    create_table "core_connector_queries", force: true do |t|
      t.integer  "project_id"
      t.integer  "freq"
      t.string   "query"
      t.string   "provider"
      t.integer  "core_authentication_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "url"
      t.json     "url_content"
      t.text     "query_url"
      t.integer  "cdn_authentication_id"
      t.string   "cdn_push_file_name"
      t.string   "cdn_push_file_path"
      t.text     "workers_to_run"
    end

    create_table "core_metadata_attachments", force: true do |t|
      t.string   "attachable_type"
      t.integer  "attachable_id"
      t.text     "uri"
      t.string   "domain"
      t.string   "filetype"
      t.text     "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "core_metadata_attachments", ["attachable_id", "attachable_type"], name: "index_attachable_on_core_metadata_attachments", using: :btree

    create_table "core_metadata_data_store_columns", force: true do |t|
      t.integer  "data_store_id"
      t.string   "column_name"
      t.string   "datatype"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_metadata_locations", force: true do |t|
      t.string   "locatable_type"
      t.integer  "locatable_id"
      t.string   "latitude"
      t.string   "longitude"
      t.string   "country_code"
      t.string   "country_name"
      t.string   "state_name"
      t.string   "state_code"
      t.string   "city"
      t.string   "name"
      t.string   "genre"
      t.text     "blurb"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "core_metadata_locations", ["locatable_id", "locatable_type"], name: "index_locatable_on_core_metadata_locations", using: :btree

    create_table "core_metadata_tags", force: true do |t|
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.string   "tag"
      t.string   "genre"
      t.string   "provider"
      t.integer  "count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "core_metadata_tags", ["tag"], name: "index_score_metadata_tags_on_tag", using: :btree
    add_index "core_metadata_tags", ["taggable_id", "taggable_type"], name: "index_taggable_on_core_metadata_tags", using: :btree

    create_table "core_nlp_dictionaries", force: true do |t|
      t.string   "name"
      t.string   "slug"
      t.json     "content"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
    end

    create_table "core_nlp_master_dictionaries", force: true do |t|
      t.string   "code"
      t.string   "genre"
      t.string   "parent_code"
      t.string   "parent_genre"
      t.string   "dataset"
      t.string   "name"
      t.float    "weight"
      t.hstore   "properties"
      t.string   "source_dictionary_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_ref_vizs", force: true do |t|
      t.string   "name"
      t.string   "genre"
      t.boolean  "is_enabled"
      t.boolean  "is_weight"
      t.boolean  "is_group"
      t.boolean  "is_stack"
      t.text     "img"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "description"
      t.json     "config"
    end

    create_table "core_util_activities", force: true do |t|
      t.integer  "trackable_id"
      t.string   "trackable_type"
      t.integer  "account_id"
      t.integer  "project_id"
      t.string   "key"
      t.text     "message"
      t.datetime "due_date"
      t.string   "alternate_model_name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "whodoneit"
    end

    create_table "core_util_config_editors", force: true do |t|
      t.integer  "account_id"
      t.integer  "project_id"
      t.string   "name"
      t.string   "slug"
      t.boolean  "to_publish"
      t.datetime "last_published_at"
      t.json     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "data_stores", force: true do |t|
      t.integer  "project_id"
      t.string   "name"
      t.string   "slug"
      t.json     "content"
      t.integer  "core_query_id"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "content_text"
      t.integer  "parent_id"
      t.integer  "cdn_authentication_id"
    end

    add_index "data_stores", ["properties"], name: "core_metadata_data_store_columns_properties", using: :gin
    add_index "data_stores", ["properties"], name: "data_stores_properties", using: :gin
    add_index "data_stores", ["slug"], name: "index_data_stores_on_slug", using: :btree

    create_table "friendly_id_slugs", force: true do |t|
      t.string   "slug",                      null: false
      t.integer  "sluggable_id",              null: false
      t.string   "sluggable_type", limit: 50
      t.string   "scope"
      t.datetime "created_at"
    end

    add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

    create_table "permissions", force: true do |t|
      t.integer  "account_id"
      t.integer  "parent_id"
      t.string   "role"
      t.string   "email"
      t.string   "status"
      t.datetime "invited_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "permissions", ["email"], name: "index_permissions_on_email", using: :btree

    create_table "projects", force: true do |t|
      t.integer  "account_id"
      t.string   "name"
      t.string   "slug"
      t.hstore   "properties"
      t.boolean  "is_public"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "projects", ["properties"], name: "projects_properties", using: :gin
    add_index "projects", ["slug"], name: "index_projects_on_slug", using: :btree

    create_table "social_mentions", force: true do |t|
      t.integer  "social_message_id"
      t.integer  "original_profile_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "screen_name"
      t.string   "official_identifier"
    end

    create_table "social_messages", force: true do |t|
      t.string   "provider"
      t.string   "official_identifier"
      t.text     "content"
      t.integer  "social_profile_id"
      t.integer  "in_reply_to_social_message_id"
      t.string   "in_reply_to_official_id"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "core_connector_query_id"
      t.text     "content_for_nlp"
      t.datetime "published_at"
    end

    add_index "social_messages", ["core_connector_query_id"], name: "index_social_messages_on_core_connector_query_id", using: :btree
    add_index "social_messages", ["official_identifier"], name: "index_social_messages_on_official_identifier", using: :btree
    add_index "social_messages", ["properties"], name: "social_messages_properties", using: :gin

    create_table "social_profiles", force: true do |t|
      t.string   "username"
      t.string   "provider"
      t.string   "official_identifier"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "social_profiles", ["official_identifier"], name: "index_social_profiles_on_official_identifier", using: :btree
    add_index "social_profiles", ["properties"], name: "social_profiles_properties", using: :gin

    create_table "versions", force: true do |t|
      t.string   "item_type",  null: false
      t.integer  "item_id",    null: false
      t.string   "event",      null: false
      t.string   "whodunnit"
      t.text     "object"
      t.datetime "created_at"
    end

    add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

    create_table "vizs", force: true do |t|
      t.integer  "project_id"
      t.integer  "data_store_id"
      t.hstore   "properties"
      t.json     "map"
      t.json     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "core_ref_viz_id"
      t.string   "title"
      t.json     "config"
    end
        
  end
end
