class APIParticulierScopesMigrationToV3 < ActiveRecord::Migration[7.1]
  def up
    # France Travail – Update Authorization Requests
    execute <<-SQL.squish
      UPDATE authorization_requests ar
      SET data = ar.data || hstore('scopes', (
        SELECT jsonb_agg(DISTINCT value)::text
        FROM (
          SELECT jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS value
          UNION
          SELECT 'pole_emploi_identifiant'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
          )
        ) s
      ))
      WHERE ar.type = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
        )
        AND NOT EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        );
    SQL

    # France Travail – Update Authorizations
    execute <<-SQL.squish
      UPDATE authorizations a
      SET data = a.data || hstore('scopes', (
        SELECT jsonb_agg(DISTINCT value)::text
        FROM (
          SELECT jsonb_array_elements_text((a.data->'scopes')::jsonb) AS value
          UNION
          SELECT 'pole_emploi_identifiant'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
          )
        ) s
      ))
      WHERE a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
        )
        AND NOT EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        );
    SQL

    # MEN – Update Authorization Requests
    execute <<-SQL.squish
      UPDATE authorization_requests ar
      SET data = ar.data || hstore('scopes', (
        SELECT jsonb_agg(DISTINCT value)::text
        FROM (
          SELECT jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS value
          UNION
          SELECT 'men_statut_identite'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
          UNION
          SELECT 'men_statut_etablissement'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
          UNION
          SELECT 'men_statut_module_elementaire_formation'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
        ) s
      ))
      WHERE ar.type = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
        );
    SQL

    # MEN – Update Authorizations
    execute <<-SQL.squish
      UPDATE authorizations a
      SET data = a.data || hstore('scopes', (
        SELECT jsonb_agg(DISTINCT value)::text
        FROM (
          SELECT jsonb_array_elements_text((a.data->'scopes')::jsonb) AS value
          UNION
          SELECT 'men_statut_identite'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
          UNION
          SELECT 'men_statut_etablissement'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
          UNION
          SELECT 'men_statut_module_elementaire_formation'
          WHERE EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
            WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
          )
        ) s
      ))
      WHERE a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
        );
    SQL
  end

  def down
    # Revert France Travail – Authorization Requests
    execute <<-SQL.squish
      UPDATE authorization_requests ar
      SET data = ar.data || hstore('scopes', (
        SELECT jsonb_agg(value)::text
        FROM (
          SELECT value
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS value
          WHERE value <> 'pole_emploi_identifiant'
        ) s
      ))
      WHERE ar.type = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        )
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
        );
    SQL

    # Revert France Travail – Authorizations
    execute <<-SQL.squish
      UPDATE authorizations a
      SET data = a.data || hstore('scopes', (
        SELECT jsonb_agg(value)::text
        FROM (
          SELECT value
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS value
          WHERE value <> 'pole_emploi_identifiant'
        ) s
      ))
      WHERE a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope = 'pole_emploi_identifiant'
        )
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('pole_emploi_identite', 'pole_emploi_contact', 'pole_emploi_adresse', 'pole_emploi_inscription')
        );
    SQL

    # Revert MEN – Authorization Requests
    execute <<-SQL.squish
      UPDATE authorization_requests ar
      SET data = ar.data || hstore('scopes', (
        SELECT jsonb_agg(value)::text
        FROM (
          SELECT value
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS value
          WHERE value NOT IN ('men_statut_identite', 'men_statut_etablissement', 'men_statut_module_elementaire_formation')
        ) s
      ))
      WHERE ar.type = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((ar.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
        );
    SQL

    # Revert MEN – Authorizations
    execute <<-SQL.squish
      UPDATE authorizations a
      SET data = a.data || hstore('scopes', (
        SELECT jsonb_agg(value)::text
        FROM (
          SELECT value
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS value
          WHERE value NOT IN ('men_statut_identite', 'men_statut_etablissement', 'men_statut_module_elementaire_formation')
        ) s
      ))
      WHERE a.authorization_request_class = 'AuthorizationRequest::APIParticulier'
        AND EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text((a.data->'scopes')::jsonb) AS scope
          WHERE scope IN ('men_statut_scolarite', 'men_statut_boursier', 'men_echelon_bourse')
        );
    SQL
  end
end
