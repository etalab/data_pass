class Import::AuthorizationRequests::DGFIPSandboxAttributes < Import::AuthorizationRequests::Base
  def affect_potential_specific_requirements
    return unless affect_potential_document('Document::ExpressionBesoinSpecifique', 'specific_requirements_document')

    authorization_request.specific_requirements = '1'
  end

  def with_franceconnect?
    enrollment_row['previous_enrollment_id'].present?
  end

  def affect_franceconnect_data
    authorization_request.modalities = authorization_request.modalities.concat(['with_france_connect'])

    france_connect_authorization = AuthorizationRequest::FranceConnect.find_by(id: enrollment_row['previous_enrollment_id'])

    authorization_request.france_connect_authorization_id = france_connect_authorization.latest_authorization.id.to_s
  end
end
