class Import::AuthorizationRequests::APIRialAttributes < Import::AuthorizationRequests::DGFIPProductionAttributes
  def affect_data
    if enrollment_row['target_api'] =~ /_unique$/
      call_sandbox_affect_attributes!
    else
      migrate_from_sandbox_to_production!
    end

    extra_affect_data

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie

    authorization_request.state = enrollment_row['status']

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  private

  def extra_affect_data; end
end
