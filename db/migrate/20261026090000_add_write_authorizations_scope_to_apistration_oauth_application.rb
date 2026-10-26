class AddWriteAuthorizationsScopeToApistrationOauthApplication < ActiveRecord::Migration[8.1]
  APISTRATION_APPLICATION_ID = 16

  def up
    execute(<<~SQL.squish)
      UPDATE oauth_applications
      SET scopes = scopes || ' write_authorizations', updated_at = NOW()
      WHERE id = #{APISTRATION_APPLICATION_ID}
        AND scopes <> ''
        AND scopes NOT LIKE '%write_authorizations%'
    SQL
  end

  def down
    execute(<<~SQL.squish)
      UPDATE oauth_applications
      SET scopes = TRIM(REPLACE(scopes, 'write_authorizations', '')), updated_at = NOW()
      WHERE id = #{APISTRATION_APPLICATION_ID}
        AND scopes LIKE '%write_authorizations%'
    SQL
  end
end
