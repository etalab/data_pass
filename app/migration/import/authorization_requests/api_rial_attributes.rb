class Import::AuthorizationRequests::APIRialAttributes < Import::AuthorizationRequests::DGFIPProductionAttributes
  def affect_data
    migrate_from_sandbox_to_production!

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie

    authorization_request.state = enrollment_row['status']

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end
end
