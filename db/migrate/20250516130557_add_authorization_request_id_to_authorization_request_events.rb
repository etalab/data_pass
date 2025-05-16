class AddAuthorizationRequestIdToAuthorizationRequestEvents < ActiveRecord::Migration[8.0]
  def up
    # First add the column without not null constraint
    add_reference :authorization_request_events, :authorization_request, foreign_key: true

    # Populate the authorization_request_id based on the polymorphic association
    execute <<~SQL
      UPDATE authorization_request_events
      SET authorization_request_id = CASE
        WHEN entity_type = 'AuthorizationRequest' THEN entity_id
        WHEN entity_type = 'DenialOfAuthorization' THEN (
          SELECT authorization_request_id FROM denial_of_authorizations WHERE id = entity_id
        )
        WHEN entity_type = 'InstructorModificationRequest' THEN (
          SELECT authorization_request_id FROM instructor_modification_requests WHERE id = entity_id
        )
        WHEN entity_type = 'Authorization' THEN (
          SELECT request_id FROM authorizations WHERE id = entity_id
        )
        WHEN entity_type = 'RevocationOfAuthorization' THEN (
          SELECT authorization_request_id FROM revocation_of_authorizations WHERE id = entity_id
        )
        WHEN entity_type = 'AuthorizationRequestTransfer' THEN (
          SELECT authorization_request_id FROM authorization_request_transfers WHERE id = entity_id
        )
        WHEN entity_type = 'AuthorizationRequestReopeningCancellation' THEN (
          SELECT request_id FROM authorization_request_reopening_cancellations WHERE id = entity_id
        )
        WHEN entity_type = 'Message' THEN (
          SELECT authorization_request_id FROM messages WHERE id = entity_id
        )
        WHEN entity_type = 'AuthorizationRequestChangelog' THEN (
          SELECT authorization_request_id FROM authorization_request_changelogs WHERE id = entity_id
        )
      END
    SQL

    # Check if there are any events where we couldn't establish a relationship (excluding bulk_update events)
    null_count = execute(<<~SQL).first["count"]
      SELECT COUNT(*) as count
      FROM authorization_request_events
      WHERE authorization_request_id IS NULL
        AND name != 'bulk_update'
    SQL

    if null_count > 0
      raise StandardError, "Found #{null_count} authorization_request_events without authorization_request_id (excluding bulk_update events): #{AuthorizationRequestEvent.where(authorization_request_id: nil).where.not(name: 'bulk_update').group(:name).count}"
    end

    # Add check constraint that requires authorization_request_id for all events except bulk_update
    execute <<~SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT authorization_request_events_auth_req_id_not_null_except_bulk
      CHECK (
        (name = 'bulk_update' AND authorization_request_id IS NULL) OR
        (name != 'bulk_update' AND authorization_request_id IS NOT NULL)
      )
    SQL
  end

  def down
    remove_index :authorization_request_events,
                 name: 'index_authorization_request_events_on_ar_id_and_created_at'
    remove_index :authorization_request_events, :authorization_request_id

    # Remove the check constraint
    execute <<~SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT authorization_request_events_auth_req_id_not_null_except_bulk
    SQL

    remove_reference :authorization_request_events, :authorization_request, foreign_key: true
  end
end
