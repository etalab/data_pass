class CreateAPIAccessGrants < ActiveRecord::Migration[8.1]
  def change
    create_api_access_grants_table
    add_api_access_grants_constraints
    add_column :data_providers, :api_contract_options, :jsonb, default: {}, null: false
  end

  private

  def create_api_access_grants_table
    create_table :api_access_grants do |t|
      t.bigint :oauth_application_id, null: false
      t.string :oauth_application_name, null: false
      t.references :data_provider, null: false, foreign_key: true
      t.string :action, null: false
      t.bigint :granted_by_id
      t.string :granted_by_email, null: false
      t.text :grant_reason, null: false
      t.datetime :granted_at, null: false
      t.bigint :revoked_by_id
      t.string :revoked_by_email
      t.boolean :revoked_automatically, default: false, null: false
      t.text :revoke_reason
      t.datetime :revoked_at
      t.timestamps
    end
  end

  def add_api_access_grants_constraints
    add_index :api_access_grants, :oauth_application_id

    add_index :api_access_grants,
      %i[oauth_application_id data_provider_id action],
      unique: true,
      where: 'revoked_at IS NULL',
      name: 'index_api_access_grants_on_active_grant'

    add_check_constraint :api_access_grants,
      '(revoked_at IS NULL) = (revoked_by_email IS NULL AND NOT revoked_automatically)',
      name: 'api_access_grants_revocation_is_complete'
  end
end
