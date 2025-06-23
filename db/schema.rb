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

ActiveRecord::Schema[8.0].define(version: 2025_06_23_080456) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

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

  create_table "admin_events", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "admin_id", null: false
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.json "before_attributes", default: {}
    t.json "after_attributes", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_events_on_admin_id"
    t.index ["entity_type", "entity_id"], name: "index_admin_events_on_entity"
  end

  create_table "authorization_documents", force: :cascade do |t|
    t.string "identifier", null: false
    t.bigint "authorization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_authorization_documents_on_authorization_id"
  end

  create_table "authorization_request_changelogs", force: :cascade do |t|
    t.json "diff", default: {}
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "legacy", default: false
    t.index ["authorization_request_id"], name: "idx_on_authorization_request_id_b550d70011"
  end

  create_table "authorization_request_events", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "authorization_request_id"
    t.index ["authorization_request_id"], name: "index_authorization_request_events_on_authorization_request_id"
    t.index ["entity_type", "entity_id"], name: "index_authorization_request_events_on_entity"
    t.index ["user_id"], name: "index_authorization_request_events_on_user_id"
    t.check_constraint "name::text !~~ 'system_%'::text AND user_id IS NOT NULL OR name::text ~~ 'system_%'::text", name: "user_id_not_null_unless_system_event"
    t.check_constraint "name::text = 'bulk_update'::text AND authorization_request_id IS NULL OR name::text <> 'bulk_update'::text AND authorization_request_id IS NOT NULL", name: "authorization_request_events_auth_req_id_not_null_except_bulk"
    t.check_constraint "name::text = 'refuse'::text AND entity_type::text = 'DenialOfAuthorization'::text OR name::text = 'request_changes'::text AND entity_type::text = 'InstructorModificationRequest'::text OR name::text = 'approve'::text AND entity_type::text = 'Authorization'::text OR name::text = 'reopen'::text AND entity_type::text = 'Authorization'::text OR name::text = 'submit'::text AND entity_type::text = 'AuthorizationRequestChangelog'::text OR name::text = 'admin_update'::text AND entity_type::text = 'AuthorizationRequestChangelog'::text OR name::text = 'applicant_message'::text AND entity_type::text = 'Message'::text OR name::text = 'instructor_message'::text AND entity_type::text = 'Message'::text OR name::text = 'revoke'::text AND entity_type::text = 'RevocationOfAuthorization'::text OR name::text = 'transfer'::text AND entity_type::text = 'AuthorizationRequestTransfer'::text OR name::text = 'cancel_reopening'::text AND entity_type::text = 'AuthorizationRequestReopeningCancellation'::text OR name::text = 'bulk_update'::text AND entity_type::text = 'BulkAuthorizationRequestUpdate'::text OR entity_type::text = 'AuthorizationRequest'::text", name: "entity_type_validation"
  end

  create_table "authorization_request_reopening_cancellations", force: :cascade do |t|
    t.text "reason"
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "idx_on_request_id_55ede89cb9"
    t.index ["user_id"], name: "index_authorization_request_reopening_cancellations_on_user_id"
  end

  create_table "authorization_request_transfers", force: :cascade do |t|
    t.bigint "authorization_request_id", null: false
    t.bigint "from_id", null: false
    t.bigint "to_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from_type", null: false
    t.string "to_type", null: false
    t.index ["authorization_request_id"], name: "idx_on_authorization_request_id_a4275ef675"
    t.index ["from_id"], name: "index_authorization_request_transfers_on_from_id"
    t.index ["to_id"], name: "index_authorization_request_transfers_on_to_id"
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
    t.datetime "reopened_at"
    t.string "external_provider_id"
    t.datetime "last_submitted_at"
    t.uuid "public_id", default: -> { "gen_random_uuid()" }
    t.boolean "reopening", default: false
    t.text "raw_attributes_from_v1"
    t.boolean "dirty_from_v1", default: false
    t.integer "copied_from_request_id"
    t.index ["applicant_id"], name: "index_authorization_requests_on_applicant_id"
    t.index ["copied_from_request_id"], name: "idx_authorization_requests_copied_from_request_id"
    t.index ["organization_id"], name: "index_authorization_requests_on_organization_id"
    t.index ["public_id"], name: "index_authorization_requests_on_public_id"
    t.index ["type", "organization_id"], name: "index_authorization_requests_on_type_and_organization_id", unique: true, where: "(((type)::text = 'AuthorizationRequest::HubEECertDC'::text) AND ((state)::text <> 'archived'::text))"
  end

  create_table "authorizations", force: :cascade do |t|
    t.hstore "data", default: {}, null: false
    t.bigint "applicant_id", null: false
    t.bigint "request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "authorization_request_class", null: false
    t.boolean "revoked", default: false
    t.string "state"
    t.index "((data -> 'france_connect_authorization_id'::text))", name: "idx_authorizations_fc_auth_id", where: "(data ? 'france_connect_authorization_id'::text)"
    t.index ["applicant_id"], name: "index_authorizations_on_applicant_id"
    t.index ["request_id"], name: "index_authorizations_on_request_id"
    t.index ["slug", "request_id"], name: "index_authorizations_on_slug_and_request_id", unique: true
    t.index ["state"], name: "index_authorizations_on_state"
  end

  create_table "bulk_authorization_request_update_notification_reads", force: :cascade do |t|
    t.bigint "bulk_authorization_request_update_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_authorization_request_update_id", "user_id"], name: "idx_on_bulk_authorization_request_update_id_user_id_bc2529b038", unique: true
    t.index ["bulk_authorization_request_update_id"], name: "idx_on_bulk_authorization_request_update_id_d1444698b3"
    t.index ["user_id"], name: "idx_on_user_id_902915981d"
  end

  create_table "bulk_authorization_request_updates", force: :cascade do |t|
    t.string "authorization_definition_uid", null: false
    t.string "reason", null: false
    t.date "application_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "denial_of_authorizations", force: :cascade do |t|
    t.string "reason", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "index_denial_of_authorizations_on_authorization_request_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "instructor_modification_requests", force: :cascade do |t|
    t.string "reason", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "idx_on_authorization_request_id_a222f7b7d6"
  end

  create_table "malware_scans", force: :cascade do |t|
    t.datetime "analyzed_at", precision: nil
    t.integer "safety_state", default: 0, null: false
    t.bigint "attachment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sha256"
    t.index ["attachment_id"], name: "index_malware_scans_on_attachment_id"
    t.index ["sha256"], name: "index_malware_scans_on_sha256"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "from_id", null: false
    t.bigint "authorization_request_id", null: false
    t.text "body", null: false
    t.datetime "sent_at"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "index_messages_on_authorization_request_id"
    t.index ["from_id"], name: "index_messages_on_from_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "siret"
    t.jsonb "mon_compte_pro_payload", default: {}
    t.datetime "last_mon_compte_pro_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "insee_payload"
    t.datetime "last_insee_payload_updated_at"
    t.string "legal_entity_id", null: false
    t.string "legal_entity_registry", default: "insee_sirene", null: false
    t.jsonb "extra_legal_entity_infos"
    t.jsonb "proconnect_payload", default: {}
    t.datetime "last_proconnect_updated_at"
    t.index "((((insee_payload -> 'etablissement'::text) -> 'uniteLegale'::text) ->> 'denominationUniteLegale'::text))", name: "index_organizations_on_denomination_unite_legale"
    t.index ["legal_entity_id", "legal_entity_registry"], name: "idx_on_legal_entity_id_legal_entity_registry_7d149bf422", unique: true
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.string "identity_provider_uid", default: "71144ab3-ee1a-4401-b7b3-79b44f7daeeb", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "current", default: false, null: false
    t.string "identity_federator", default: "mon_compte_pro", null: false
    t.index ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organizations_users_on_organization_id"
    t.index ["user_id", "current"], name: "index_organizations_users_on_user_id_and_current", where: "(current = true)"
    t.index ["user_id"], name: "index_organizations_users_on_user_id"
  end

  create_table "revocation_of_authorizations", force: :cascade do |t|
    t.string "reason", null: false
    t.bigint "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_request_id"], name: "index_revocation_of_authorizations_on_authorization_request_id"
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
    t.jsonb "settings", default: {}
    t.index ["current_organization_id"], name: "index_users_on_current_organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_id"], name: "index_users_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["settings"], name: "index_users_on_settings", using: :gin
  end

  create_table "verified_emails", force: :cascade do |t|
    t.string "email", null: false
    t.string "status", default: "unknown", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_verified_emails_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_events", "users", column: "admin_id"
  add_foreign_key "authorization_documents", "authorizations"
  add_foreign_key "authorization_request_changelogs", "authorization_requests"
  add_foreign_key "authorization_request_events", "authorization_requests"
  add_foreign_key "authorization_request_reopening_cancellations", "authorization_requests", column: "request_id"
  add_foreign_key "authorization_request_reopening_cancellations", "users"
  add_foreign_key "authorization_request_transfers", "authorization_requests"
  add_foreign_key "authorization_requests", "authorization_requests", column: "copied_from_request_id", name: "fk_authorization_requests_copied_from_request", on_delete: :nullify
  add_foreign_key "authorization_requests", "users", column: "applicant_id"
  add_foreign_key "authorizations", "authorization_requests", column: "request_id"
  add_foreign_key "authorizations", "users", column: "applicant_id"
  add_foreign_key "bulk_authorization_request_update_notification_reads", "bulk_authorization_request_updates"
  add_foreign_key "bulk_authorization_request_update_notification_reads", "users"
  add_foreign_key "denial_of_authorizations", "authorization_requests"
  add_foreign_key "instructor_modification_requests", "authorization_requests"
  add_foreign_key "malware_scans", "active_storage_attachments", column: "attachment_id"
  add_foreign_key "messages", "authorization_requests"
  add_foreign_key "messages", "users", column: "from_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "revocation_of_authorizations", "authorization_requests"
end
