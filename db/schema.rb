# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151119180508) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "unaccent"

  create_table "accounts", force: :cascade do |t|
    t.string   "username"
    t.string   "email",                  default: "", null: false
    t.string   "slug"
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

  create_table "core_datacast_outputs", force: :cascade do |t|
    t.string   "datacast_identifier", null: false
    t.integer  "core_datacast_id",    null: false
    t.text     "output"
    t.text     "fingerprint"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "core_datacast_outputs", ["datacast_identifier"], name: "index_core_datacast_outputs_on_datacast_identifier", unique: true, using: :btree

  create_table "core_datacast_pulls", force: :cascade do |t|
    t.integer  "core_project_id"
    t.text     "file_url"
    t.boolean  "first_row_header"
    t.string   "status"
    t.text     "error_messages"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "core_db_connection_id"
    t.string   "table_name"
  end

  create_table "core_datacasts", force: :cascade do |t|
    t.integer  "core_project_id"
    t.integer  "core_db_connection_id"
    t.string   "name"
    t.string   "identifier"
    t.hstore   "properties"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "params_object",          default: {}
    t.json     "column_properties",      default: {}
    t.datetime "last_run_at"
    t.datetime "last_data_changed_at"
    t.integer  "count_of_queries"
    t.float    "average_execution_time"
    t.float    "size"
    t.string   "slug"
    t.string   "table_name"
  end

  create_table "core_db_connections", force: :cascade do |t|
    t.string   "name"
    t.string   "adapter"
    t.hstore   "properties"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "core_project_id"
  end

  create_table "core_permissions", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "role"
    t.string   "email"
    t.string   "status"
    t.datetime "invited_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_owner_team"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "core_project_id"
  end

  add_index "core_permissions", ["email"], name: "index_core_permissions_on_email", using: :btree

  create_table "core_projects", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "slug"
    t.hstore   "properties"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "core_projects", ["properties"], name: "projects_properties", using: :gin
  add_index "core_projects", ["slug"], name: "index_core_projects_on_slug", using: :btree

  create_table "core_session_impls", force: :cascade do |t|
    t.string   "session_id"
    t.integer  "account_id"
    t.string   "ip"
    t.string   "device"
    t.string   "browser"
    t.text     "blurb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "core_viz_id"
  end

  add_index "core_session_impls", ["account_id"], name: "index_core_session_impls_on_account_id", using: :btree
  add_index "core_session_impls", ["session_id"], name: "index_core_session_impls_on_session_id", unique: true, using: :btree

  create_table "core_sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "core_sessions", ["session_id"], name: "index_core_sessions_on_session_id", unique: true, using: :btree
  add_index "core_sessions", ["updated_at"], name: "index_core_sessions_on_updated_at", using: :btree

  create_table "core_templates", force: :cascade do |t|
    t.string   "name"
    t.text     "html_content"
    t.string   "genre"
    t.json     "required_variables", default: {}
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "core_themes", force: :cascade do |t|
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

  create_table "core_time_aggregations", force: :cascade do |t|
    t.string   "aggregation_level"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.string   "aggregation_level_value"
    t.string   "metric"
    t.integer  "value"
    t.integer  "difference_from_previous_value"
    t.boolean  "is_positive_value"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "aggregation_index"
    t.string   "aggregation_value_to_display"
  end

  create_table "core_tokens", force: :cascade do |t|
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

  create_table "core_vizs", force: :cascade do |t|
    t.integer  "core_project_id"
    t.hstore   "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.json     "config"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "ref_chart_combination_code"
    t.string   "core_datacast_identifier"
    t.boolean  "filter_present"
    t.boolean  "is_autogenerated",           default: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
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

  create_table "impl_aggregation_datacasts", force: :cascade do |t|
    t.integer  "impl_aggregation_id"
    t.string   "core_datacast_identifier"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "impl_aggregation_relations", force: :cascade do |t|
    t.integer  "impl_parent_id"
    t.string   "impl_parent_genre"
    t.integer  "impl_child_id"
    t.string   "impl_child_genre"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "impl_aggregations", force: :cascade do |t|
    t.integer  "core_project_id"
    t.string   "genre"
    t.string   "name"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "status"
    t.string   "error_messages"
    t.hstore   "properties"
  end

  create_table "impl_data_provider_data_sets", force: :cascade do |t|
    t.integer  "impl_aggregation_id"
    t.integer  "impl_data_set_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "impl_datasets", force: :cascade do |t|
    t.string   "data_set_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "status"
    t.string   "error_messages"
    t.integer  "impl_aggregation_id"
    t.string   "name"
  end

  create_table "impl_outputs", force: :cascade do |t|
    t.string   "genre"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "impl_parent_type"
    t.integer  "impl_parent_id"
    t.string   "status"
    t.string   "error_messages"
    t.string   "key"
    t.string   "value"
    t.hstore   "properties"
  end

  create_table "impl_reports", force: :cascade do |t|
    t.integer  "impl_aggregation_id"
    t.integer  "core_template_id"
    t.string   "name"
    t.string   "slug"
    t.text     "html_content"
    t.json     "variable_object"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "is_autogenerated",    default: false
    t.integer  "core_project_id",     default: 1
  end

  add_index "impl_reports", ["slug"], name: "index_impl_reports_on_slug", unique: true, using: :btree

  create_table "impl_static_attributes", force: :cascade do |t|
    t.integer  "impl_output_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "username"
    t.datetime "created_time"
    t.string   "user_id"
    t.string   "source"
    t.string   "profile_picture_url"
    t.hstore   "pic"
    t.string   "tags",                default: [],              array: true
    t.string   "post_id"
    t.text     "content"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "ref_charts", force: :cascade do |t|
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

  create_table "ref_country_codes", force: :cascade do |t|
    t.string   "country"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
