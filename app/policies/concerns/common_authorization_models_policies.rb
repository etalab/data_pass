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

  def authorization_definition
    fail NoImplementedError
  end

  private

  def unicity_constraint_violated?
    return false unless authorization_definition.unique

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization && current_organization.active_authorization_requests.where(type: authorization_request_class).any?
  end
end
