class AddAutoInstructionConstraintToAuthorizationRequestEvents < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'auto_reject' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'auto_approve' AND entity_type = 'Authorization') OR
        (name = 'auto_generate' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_update' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_change' AND entity_type = 'AdminChange') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
        (name = 'revoke' AND entity_type = 'RevocationOfAuthorization') OR
        (name = 'transfer' AND entity_type = 'AuthorizationRequestTransfer') OR
        (name = 'cancel_reopening' AND entity_type = 'AuthorizationRequestReopeningCancellation') OR
        (name = 'bulk_update' AND entity_type = 'BulkAuthorizationRequestUpdate') OR
        (name = 'claim' AND entity_type = 'InstructorDraftRequest') OR
        (name = 'create_by_api' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'update_by_api' AND entity_type = 'AuthorizationRequestChangelog') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'auto_generate' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_update' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_change' AND entity_type = 'AdminChange') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
        (name = 'revoke' AND entity_type = 'RevocationOfAuthorization') OR
        (name = 'transfer' AND entity_type = 'AuthorizationRequestTransfer') OR
        (name = 'cancel_reopening' AND entity_type = 'AuthorizationRequestReopeningCancellation') OR
        (name = 'bulk_update' AND entity_type = 'BulkAuthorizationRequestUpdate') OR
        (name = 'claim' AND entity_type = 'InstructorDraftRequest') OR
        (name = 'create_by_api' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'update_by_api' AND entity_type = 'AuthorizationRequestChangelog') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end
end
