class AddDbConnectionAndDatacast < ActiveRecord::Migration
  def change
    create_table "core_db_connections", force: true do |t|
      t.string   "name"
      t.string   "adapter"
      t.hstore   "properties"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "core_project_id"
    end

    create_table "core_datacasts", force: true do |t|
      t.integer  "core_project_id"
      t.integer  "core_db_connection_id"
      t.string   "name"
      t.string   "identifier"
      t.hstore   "properties"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.json     "params_object",         default: {}
    end
  end
end
