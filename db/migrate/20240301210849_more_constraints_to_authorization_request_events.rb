class MoreConstraintsToAuthorizationRequestEvents < ActiveRecord::Migration[7.1]
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
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
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
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end
end
