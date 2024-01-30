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

ActiveRecord::Schema[7.1].define(version: 2024_01_30_155005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authorization_request_events", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_authorization_request_events_on_entity"
    t.index ["user_id"], name: "index_authorization_request_events_on_user_id"
    t.check_constraint "name::text !~~ 'system_%'::text AND user_id IS NOT NULL OR name::text ~~ 'system_%'::text", name: "user_id_not_null_unless_system_event"
    t.check_constraint "name::text = 'refuse'::text AND entity_type::text = 'DenialOfAuthorization'::text OR name::text = 'request_changes'::text AND entity_type::text = 'InstructorModificationRequest'::text OR entity_type::text = 'AuthorizationRequest'::text", name: "entity_type_validation"
  end

  create_table "authorization_requests", force: :cascade do |t|
    t.string "type", null: false
    t.string "state", default: "draft", null: false
    t.bigint "organization_id", null: false
    t.integer "applicant_id", null: false
    t.boolean "terms_of_service_accepted", default: false, null: false
    t.boolean "data_protection_officer_informed", default: false, null: false
    t.hstore "data", default: {}
    t.datetime "last_validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "form_uid", null: false
    t.index ["applicant_id"], name: "index_authorization_requests_on_applicant_id"
    t.index ["organization_id"], name: "index_authorization_requests_on_organization_id"
  end

  create_table "authorizations", force: :cascade do |t|
    t.hstore "data", default: {}, null: false
    t.bigint "applicant_id", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_authorizations_on_applicant_id"
    t.index ["authorization_request_id"], name: "index_authorizations_on_authorization_request_id"
  end

  create_table "denial_of_authorizations", force: :cascade do |t|
    t.string "reason", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "index_denial_of_authorizations_on_authorization_request_id"
  end

  create_table "instructor_modification_requests", force: :cascade do |t|
    t.string "reason", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "idx_on_authorization_request_id_a222f7b7d6"
  end

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
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_organization_id"
    t.string "phone_number"
    t.boolean "phone_number_verified", default: false
    t.string "roles", default: [], array: true
    t.index ["current_organization_id"], name: "index_users_on_current_organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_id"], name: "index_users_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "authorizations", "authorization_requests"
  add_foreign_key "authorizations", "users", column: "applicant_id"
  add_foreign_key "denial_of_authorizations", "authorization_requests"
  add_foreign_key "instructor_modification_requests", "authorization_requests"
end
