class AddClaimConstraintToAuthorizationRequestEvents < ActiveRecord::Migration[8.0]
  # rubocop:disable Metrics/MethodLength
  def up
    execute <<-SQL.squish
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL.squish
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_update' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
        (name = 'revoke' AND entity_type = 'RevocationOfAuthorization') OR
        (name = 'transfer' AND entity_type = 'AuthorizationRequestTransfer') OR
        (name = 'cancel_reopening' AND entity_type = 'AuthorizationRequestReopeningCancellation') OR
        (name = 'bulk_update' AND entity_type = 'BulkAuthorizationRequestUpdate') OR
        (name = 'claim' AND entity_type = 'InstructorDraftRequest') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end

  def down
    execute <<-SQL.squish
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL.squish
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_update' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
        (name = 'revoke' AND entity_type = 'RevocationOfAuthorization') OR
        (name = 'transfer' AND entity_type = 'AuthorizationRequestTransfer') OR
        (name = 'cancel_reopening' AND entity_type = 'AuthorizationRequestReopeningCancellation') OR
        (name = 'bulk_update' AND entity_type = 'BulkAuthorizationRequestUpdate') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end
  # rubocop:enable Metrics/MethodLength
end
