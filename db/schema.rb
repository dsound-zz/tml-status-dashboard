# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_20_232140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "state_statuses", force: :cascade do |t|
    t.bigint "state_id", null: false
    t.string "status"
    t.datetime "planned_outage_start"
    t.datetime "planned_outage_end"
    t.string "outage_reason"
    t.integer "response_time_ms"
    t.decimal "uptime_30d", precision: 5, scale: 2
    t.datetime "last_checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_state_statuses_on_state_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "department_name"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "api_type"
    t.string "api_version"
    t.string "data_format"
    t.string "auth_method"
    t.text "protocol_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_states_on_abbreviation", unique: true
  end

  add_foreign_key "state_statuses", "states"
end
