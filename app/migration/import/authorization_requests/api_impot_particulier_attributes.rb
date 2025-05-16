class Import::AuthorizationRequests::APIImpotParticulierAttributes < Import::AuthorizationRequests::APIImpotParticulierSandboxAttributes
  include Import::AuthorizationRequests::DGFIPProduction

  def affect_data
    if enrollment_row['target_api'] =~ /_unique$/
      call_sandbox_affect_attributes!
    else
      migrate_from_sandbox_to_production!
    end

    affect_form_uid

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie
    affect_extra_cadre_juridique

    handle_franceconnect

    authorization_request.state = enrollment_row['status']

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  private

  def handle_franceconnect
    return unless enrollment_row['target_api'] == 'api_impot_particulier_fc_production'

    authorization_request.modalities ||= []
    authorization_request.modalities = authorization_request.modalities.concat(['with_france_connect'])
    authorization_request.modalities = authorization_request.modalities.uniq
  end

  def demarche_to_form_uid
    form_uid = case enrollment_row['demarche']
      when 'eligibilite_lep', 'quotient_familial', 'default'
        'api-impot-particulier-production'
      when 'migration_api_particulier'
        'api-impot-particulier-production'
      when 'activites_periscolaires'
        'api-impot-particulier-activites-periscolaires-production'
      when 'aides_sociales_facultatives'
        'api-impot-particulier-aides-sociales-facultatives-production'
      when 'cantine_scolaire'
        'api-impot-particulier-cantine-scolaire-production'
      when 'carte_transport'
        'api-impot-particulier-carte-transport-production'
      when 'place_creche'
        'api-impot-particulier-place-creche-production'
      when 'stationnement_residentiel', 'carte_stationnement'
        'api-impot-particulier-stationnement-residentiel-production'
      else
        'api-impot-particulier-production'
      end

    form_uid = form_uid.gsub('-production', '-editeur') if enrollment_row['target_api'] =~ /_unique$/

    form_uid
  end
end
