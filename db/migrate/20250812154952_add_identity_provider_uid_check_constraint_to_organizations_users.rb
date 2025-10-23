class AddIdentityProviderUidCheckConstraintToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    # Allow NULL identity_provider_uid when identity_federator is 'unknown'
    # but require it for all other identity_federator values
    reversible do |direction|
      direction.up do
        # First, remove the NOT NULL constraint on identity_provider_uid
        change_column_null :organizations_users, :identity_provider_uid, true
        
        # Then add the check constraint
        execute <<-SQL
          ALTER TABLE organizations_users 
          DROP CONSTRAINT IF EXISTS organizations_users_identity_provider_uid_null,
          ADD CONSTRAINT organizations_users_identity_provider_uid_null 
          CHECK (
            (identity_federator = 'unknown' AND identity_provider_uid IS NULL) OR
            (identity_federator != 'unknown' AND identity_provider_uid IS NOT NULL)
          );
        SQL
      end

      direction.down do
        # Remove the check constraint
        execute <<-SQL
          ALTER TABLE organizations_users 
          DROP CONSTRAINT IF EXISTS organizations_users_identity_provider_uid_null;
        SQL
        
        # Restore the NOT NULL constraint
        change_column_null :organizations_users, :identity_provider_uid, false
      end
    end
  end
end
