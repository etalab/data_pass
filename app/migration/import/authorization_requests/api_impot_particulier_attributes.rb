class Import::AuthorizationRequests::APIImpotParticulierAttributes < Import::AuthorizationRequests::APIImpotParticulierSandboxAttributes
  include Import::AuthorizationRequests::DGFIPProduction

  def affect_data
    migrate_from_sandbox_to_production! unless enrollment_row['target_api'] =~ /_unique$/

    affect_form_uid

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie

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

  # FIXME
  def affect_form_uid
    authorization_request.form_uid = authorization_request.definition.available_forms.first.id
  end
end
