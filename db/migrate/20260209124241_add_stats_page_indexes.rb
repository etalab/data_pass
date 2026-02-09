class AddStatsPageIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index :authorization_request_events,
      %i[name authorization_request_id created_at],
      name: 'idx_auth_req_events_name_request_id_created_at',
      algorithm: :concurrently,
      if_not_exists: true

    add_index :authorization_request_events,
      %i[name created_at],
      name: 'idx_auth_req_events_name_created_at',
      algorithm: :concurrently,
      if_not_exists: true

    add_index :authorization_requests,
      [:type],
      name: 'index_authorization_requests_on_type',
      algorithm: :concurrently,
      if_not_exists: true

    add_index :authorization_requests,
      [:form_uid],
      name: 'index_authorization_requests_on_form_uid',
      algorithm: :concurrently,
      if_not_exists: true
  end

  def down
    remove_index :authorization_request_events,
      name: 'idx_auth_req_events_name_request_id_created_at',
      algorithm: :concurrently,
      if_exists: true

    remove_index :authorization_request_events,
      name: 'idx_auth_req_events_name_created_at',
      algorithm: :concurrently,
      if_exists: true

    remove_index :authorization_requests,
      name: 'index_authorization_requests_on_type',
      algorithm: :concurrently,
      if_exists: true

    remove_index :authorization_requests,
      name: 'index_authorization_requests_on_form_uid',
      algorithm: :concurrently,
      if_exists: true
  end
end
