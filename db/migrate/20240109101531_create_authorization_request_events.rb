class CreateAuthorizationRequestEvents < ActiveRecord::Migration[7.1]
  def up
    create_table :authorization_request_events do |t|
      t.string :name, null: false
      t.references :user
      t.references :entity, polymorphic: true, null: false

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT user_id_not_null_unless_system_event
      CHECK (
        (name NOT LIKE 'system_%' AND user_id IS NOT NULL) OR
        (name LIKE 'system_%')
      )
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT user_id_not_null_unless_system_event
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    drop_table :authorization_request_events
  end
end
