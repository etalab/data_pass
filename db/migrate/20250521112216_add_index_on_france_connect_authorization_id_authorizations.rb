class AddIndexOnFranceConnectAuthorizationIdAuthorizations < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE INDEX idx_authorizations_fc_auth_id
      ON authorizations ((data->'france_connect_authorization_id'))
      WHERE data ? 'france_connect_authorization_id';
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS idx_authorizations_fc_auth_id;
    SQL
  end
end
