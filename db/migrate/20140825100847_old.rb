class Old < ActiveRecord::Migration
  def change
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    enable_extension "hstore"
    enable_extension "unaccent"

    create_table "accounts", force: true do |t|
      t.string   "username"
      t.string   "email",                  default: "", null: false
      t.string   "slug"
      t.string   "accountable_type"
      t.hstore   "properties"
      t.string   "encrypted_password",     default: "", null: false
      t.string   "reset_password_token"
      t.string   "confirmation_token"
      t.string   "unconfirmed_email"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "authentication_token"
      t.hstore   "devis"
      t.integer  "sign_in_count"
      t.datetime "confirmation_sent_at"
      t.datetime "reset_password_sent_at"
    end

    add_index "accounts", ["authentication_token"], name: "index_accounts_on_authentication_token", unique: true, using: :btree
    add_index "accounts", ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true, using: :btree
    add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
    add_index "accounts", ["properties"], name: "accounts_properties", using: :gin
    add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
    add_index "accounts", ["slug"], name: "index_accounts_on_slug", unique: true, using: :btree
    add_index "accounts", ["username"], name: "index_accounts_on_username", unique: true, using: :btree

    create_table "cerebro_accounts", force: true do |t|
      t.string   "email"
      t.integer  "account_id"
      t.hstore   "properties"
      t.json     "response"
      t.datetime "request_sent_at"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cerebro_socials", force: true do |t|
      t.integer  "cerebro_account_id"
      t.string   "source"
      t.string   "source_name"
      t.text     "photo_url"
      t.text     "bio"
      t.text     "url"
      t.string   "identifier"
      t.string   "username"
      t.string   "followers"
      t.string   "following"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cerebro_websites", force: true do |t|
      t.integer  "cerebro_account_id"
      t.text     "url"
      t.string   "genre"
      t.string   "handle"
      t.string   "client"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cerebro_works", force: true do |t|
      t.integer  "cerebro_account_id"
      t.string   "start_date"
      t.string   "end_date"
      t.string   "title"
      t.string   "is_primary"
      t.string   "name"
      t.string   "is_current"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_account_emails", force: true do |t|
      t.integer  "account_id"
      t.string   "email"
      t.string   "confirmation_token"
      t.datetime "confirmed_at"
      t.boolean  "is_primary"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_account_images", force: true do |t|
      t.integer  "account_id"
      t.string   "filetype"
      t.text     "image_url"
      t.string   "filesize"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.hstore   "properties"
    end

    create_table "core_configuration_editors", force: true do |t|
      t.integer  "account_id"
      t.integer  "core_project_id"
      t.string   "name"
      t.string   "slug"
      t.boolean  "to_publish"
      t.datetime "last_published_at"
      t.json     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.hstore   "properties"
      t.integer  "created_by"
      t.integer  "updated_by"
    end

    create_table "core_custom_dashboards", force: true do |t|
      t.integer  "core_project_id"
      t.string   "name"
      t.hstore   "properties"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "slug"
    end

    create_table "core_data_store_pulls", force: true do |t|
      t.integer  "core_project_id"
      t.text     "file_url"
      t.boolean  "first_row_header"
      t.string   "status"
      t.text     "error_messages"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_data_stores", force: true do |t|
      t.integer  "core_project_id"
      t.string   "name"
      t.string   "slug"
      t.hstore   "properties"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.integer  "clone_parent_id"
      t.string   "table_name"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.string   "genre_class"
      t.boolean  "is_verified_dictionary"
      t.json     "join_query"
      t.text     "meta_description"
    end

    add_index "core_data_stores", ["properties"], name: "core_metadata_data_store_columns_properties", using: :gin
    add_index "core_data_stores", ["properties"], name: "data_stores_properties", using: :gin
    add_index "core_data_stores", ["slug"], name: "index_core_data_stores_on_slug", using: :btree

    create_table "core_map_files", force: true do |t|
      t.integer  "account_id"
      t.boolean  "is_public"
      t.string   "name"
      t.string   "size"
      t.string   "filetype"
      t.hstore   "properties"
      t.boolean  "is_verified"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_permissions", force: true do |t|
      t.integer  "account_id"
      t.integer  "organisation_id"
      t.string   "role"
      t.string   "email"
      t.string   "status"
      t.datetime "invited_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "core_team_id"
      t.boolean  "is_owner_team"
      t.integer  "created_by"
      t.integer  "updated_by"
    end

    add_index "core_permissions", ["email"], name: "index_core_permissions_on_email", using: :btree

    create_table "core_project_oauths", force: true do |t|
      t.integer  "core_project_id"
      t.string   "unique_id"
      t.string   "provider"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.json     "properties"
    end

    create_table "core_projects", force: true do |t|
      t.integer  "account_id"
      t.string   "name"
      t.string   "slug"
      t.hstore   "properties"
      t.boolean  "is_public"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.string   "ref_plan_slug"
    end

    add_index "core_projects", ["properties"], name: "projects_properties", using: :gin
    add_index "core_projects", ["slug"], name: "index_core_projects_on_slug", using: :btree

    create_table "core_referral_gifts", force: true do |t|
      t.integer  "account_id"
      t.integer  "project_id"
      t.integer  "referral_id"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_referrals", force: true do |t|
      t.string   "email"
      t.integer  "account_id"
      t.integer  "referered_id"
      t.boolean  "is_eligible"
      t.text     "notes"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_session_actions", force: true do |t|
      t.integer  "account_id"
      t.integer  "core_session_impl_id"
      t.string   "genre"
      t.integer  "organisation_id"
      t.integer  "project_id"
      t.string   "objectable_type"
      t.integer  "objectable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "message"
      t.integer  "count"
    end

    create_table "core_session_impls", force: true do |t|
      t.string   "session_id"
      t.integer  "account_id"
      t.string   "ip"
      t.string   "device"
      t.string   "browser"
      t.text     "blurb"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "core_viz_id"
      t.integer  "core_map_file_id"
    end

    add_index "core_session_impls", ["account_id"], name: "index_core_session_impls_on_account_id", using: :btree
    add_index "core_session_impls", ["session_id"], name: "index_core_session_impls_on_session_id", unique: true, using: :btree

    create_table "core_sessions", force: true do |t|
      t.string   "session_id", null: false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "core_sessions", ["session_id"], name: "index_core_sessions_on_session_id", unique: true, using: :btree
    add_index "core_sessions", ["updated_at"], name: "index_core_sessions_on_updated_at", using: :btree

    create_table "core_team_projects", force: true do |t|
      t.integer  "core_team_id"
      t.integer  "core_project_id"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_teams", force: true do |t|
      t.integer  "organisation_id"
      t.string   "name"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "role"
      t.boolean  "is_owner_team"
    end

    create_table "core_themes", force: true do |t|
      t.integer  "account_id"
      t.string   "name"
      t.integer  "sort_order"
      t.json     "config"
      t.text     "image_url"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "core_tokens", force: true do |t|
      t.integer  "account_id"
      t.integer  "core_project_id"
      t.string   "api_token"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
    end

    add_index "core_tokens", ["api_token"], name: "index_core_tokens_on_api_token", using: :btree

    create_table "core_vizs", force: true do |t|
      t.integer  "core_project_id"
      t.integer  "core_data_store_id"
      t.hstore   "properties"
      t.json     "pykquery_object"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.json     "config"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.string   "ref_chart_combination_code"
      t.integer  "refresh_freq_in_minutes"
      t.text     "output"
      t.datetime "refreshed_at"
      t.string   "datagram_identifier"
      t.boolean  "is_static"
      t.boolean  "was_output_big"
    end

    add_index "core_vizs", ["datagram_identifier"], name: "index_core_vizs_on_datagram_identifier", using: :btree

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

    create_table "ref_charts", force: true do |t|
      t.string  "name"
      t.text    "description"
      t.text    "img_small"
      t.string  "genre"
      t.text    "map"
      t.text    "api"
      t.integer "created_by"
      t.integer "updated_by"
      t.string  "img_data_mapping"
      t.string  "slug"
      t.string  "combination_code", limit: 6
      t.string  "source"
      t.string  "file_path"
      t.integer "sort_order"
    end

    create_table "ref_plans", force: true do |t|
      t.string   "name"
      t.string   "slug"
      t.hstore   "properties"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    
  end
end