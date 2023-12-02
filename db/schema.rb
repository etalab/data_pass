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

ActiveRecord::Schema[7.1].define(version: 2023_12_02_181614) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organizations", force: :cascade do |t|
    t.string "siret", null: false
    t.jsonb "mon_compte_pro_payload", default: {}, null: false
    t.datetime "last_mon_compte_pro_updated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["siret"], name: "index_organizations_on_siret", unique: true
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.index ["organization_id"], name: "index_organizations_users_on_organization_id"
    t.index ["user_id"], name: "index_organizations_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "family_name"
    t.string "given_name"
    t.string "job_title"
    t.boolean "email_verified", default: false
    t.string "external_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_id"], name: "index_users_on_external_id", unique: true
  end

end
