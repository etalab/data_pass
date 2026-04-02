class CleanDormantFranceConnectDataOnAPIParticulierRequests < ActiveRecord::Migration[8.1]
  def up
    clean_authorization_requests
    clean_authorizations
  end

  private

  def clean_authorization_requests
    execute <<~SQL.squish
      UPDATE authorization_requests
      SET data = delete(delete(delete(data, 'fc_eidas'), 'fc_cadre_juridique_nature'), 'fc_cadre_juridique_url')
      WHERE type = 'AuthorizationRequest::APIParticulier'
        AND (
          (data -> 'fc_eidas') IS NOT NULL AND (data -> 'fc_eidas') != ''
          OR (data -> 'fc_cadre_juridique_nature') IS NOT NULL AND (data -> 'fc_cadre_juridique_nature') != ''
          OR (data -> 'fc_cadre_juridique_url') IS NOT NULL AND (data -> 'fc_cadre_juridique_url') != ''
        )
        AND (
          (data -> 'modalities') IS NULL
          OR (data -> 'modalities') NOT LIKE '%france_connect%'
        )
    SQL
  end

  def clean_authorizations
    execute <<~SQL.squish
      UPDATE authorizations
      SET data = delete(delete(delete(data, 'fc_eidas'), 'fc_cadre_juridique_nature'), 'fc_cadre_juridique_url')
      WHERE authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND (
          (data -> 'fc_eidas') IS NOT NULL AND (data -> 'fc_eidas') != ''
          OR (data -> 'fc_cadre_juridique_nature') IS NOT NULL AND (data -> 'fc_cadre_juridique_nature') != ''
          OR (data -> 'fc_cadre_juridique_url') IS NOT NULL AND (data -> 'fc_cadre_juridique_url') != ''
        )
        AND (
          (data -> 'modalities') IS NULL
          OR (data -> 'modalities') NOT LIKE '%france_connect%'
        )
    SQL
  end

  def down
    # Pas de rollback : les données étaient dormantes et incorrectes
  end
end
