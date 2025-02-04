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

  # FIXME
  def affect_form_uid
    authorization_request.form_uid = authorization_request.definition.available_forms.first.id
  end
end
