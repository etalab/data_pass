module CommonAuthorizationModelsPolicies
  def new?
    record.startable_by_applicant
  end

  def create?
    new? && !unicity_constraint_violated?
  end

  protected

  def authorization_request_class
    fail NoImplementedError
  end

  def scopes
    fail NoImplementedError
  end

  private

  def unicity_constraint_violated?
    return false unless (hubee_cert_dc? || hubee_dila?)

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization && current_organization.active_authorization_requests.where(type: authorization_request_class).any?
  end

  def hubee_cert_dc?
    authorization_request_class == 'AuthorizationRequest::HubEECertDC'
  end

  def hubee_dila?
    authorization_request_class == 'AuthorizationRequest::HubEEDila'
  end
end
