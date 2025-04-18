class Import::AuthorizationRequests::APISFiPAttributes < Import::AuthorizationRequests::APISFiPSandboxAttributes
  include Import::AuthorizationRequests::DGFIPProduction

  def affect_data
    migrate_from_sandbox_to_production! unless enrollment_row['target_api'] =~ /_unique$/

    affect_form_uid

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie

    authorization_request.state = enrollment_row['status']

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  def demarche_to_form_uid
    form_uid = case enrollment_row['demarche']
      when 'aides_sociales_facultatives'
        'api-sfip-aides-sociales-facultatives-sandbox'
      when 'cantine_scolaire'
        'api-sfip-cantine-scolaire-sandbox'
      when 'activites_periscolaires'
        'api-sfip-activites-periscolaires-sandbox'
      when 'place_creche'
        'api-sfip-place-creche-sandbox'
      when 'stationnement_residentiel', 'carte_stationnement'
        'api-sfip-stationnement-residentiel-sandbox'
      when 'carte_transport'
        'api-sfip-carte-transport-sandbox'
      when 'eligibilite_lep', 'migration_api_particulier'
        'api-sfip-sandbox'
      else
        'api-sfip-sandbox'
      end

    form_uid += '-editeur' if enrollment_row['target_api'] =~ /_unique$/

    form_uid
  end
end
