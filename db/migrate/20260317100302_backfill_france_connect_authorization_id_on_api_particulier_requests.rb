class BackfillFranceConnectAuthorizationIdOnAPIParticulierRequests < ActiveRecord::Migration[7.2]
  def up
    backfill_authorization_requests
    backfill_authorizations
  end

  def down
    rollback_authorizations
    rollback_authorization_requests
  end

  private

  def backfill_authorization_requests
    execute <<~SQL.squish
      UPDATE authorization_requests ar
      SET data = ar.data || hstore('france_connect_authorization_id', latest_fc.id::text)
      FROM (
        SELECT DISTINCT ON (a.request_id) a.request_id, a.id
        FROM authorizations a
        WHERE a.authorization_request_class = 'AuthorizationRequest::FranceConnect'
          AND a.parent_authorization_id IS NOT NULL
        ORDER BY a.request_id, a.created_at DESC
      ) latest_fc
      WHERE ar.id = latest_fc.request_id
        AND ar.type = 'AuthorizationRequest::APIParticulier'
        AND (ar.data -> 'france_connect_authorization_id') IS NULL
    SQL
  end

  def backfill_authorizations
    execute <<~SQL.squish
      UPDATE authorizations a
      SET data = a.data || hstore('france_connect_authorization_id', (ar.data -> 'france_connect_authorization_id'))
      FROM authorization_requests ar
      WHERE a.request_id = ar.id
        AND ar.type = 'AuthorizationRequest::APIParticulier'
        AND (ar.data -> 'france_connect_authorization_id') IS NOT NULL
        AND a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND (a.data -> 'france_connect_authorization_id') IS NULL
    SQL
  end

  def rollback_authorizations
    execute <<~SQL.squish
      UPDATE authorizations a
      SET data = delete(a.data, 'france_connect_authorization_id')
      FROM authorization_requests ar
      WHERE a.request_id = ar.id
        AND ar.type = 'AuthorizationRequest::APIParticulier'
        AND a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
    SQL
  end

  def rollback_authorization_requests
    execute <<~SQL.squish
      UPDATE authorization_requests ar
      SET data = delete(ar.data, 'france_connect_authorization_id')
      FROM authorizations a
      WHERE a.request_id = ar.id
        AND a.authorization_request_class = 'AuthorizationRequest::FranceConnect'
        AND a.parent_authorization_id IS NOT NULL
        AND ar.type = 'AuthorizationRequest::APIParticulier'
    SQL
  end
end
