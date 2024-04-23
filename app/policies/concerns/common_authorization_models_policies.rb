module CommonAuthorizationModelsPolicies
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  def create?
    new?
  end

  protected

  def authorization_request_class
    fail NoImplementedError
  end

  private

  def unicity_constraint_violated?
    return false unless hubee_cert_dc?

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization && current_organization.active_authorization_requests.where(type: authorization_request_class).any?
  end

  def hubee_cert_dc?
    authorization_request_class == 'AuthorizationRequest::HubEECertDC'
  end
end
