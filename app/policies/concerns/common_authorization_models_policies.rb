module CommonAuthorizationModelsPolicies
  def new?
    startable_by_applicant &&
      active_organization?
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

  def startable_by_applicant
    record.startable_by_applicant
  rescue NoMethodError
    true
  end

  def active_organization?
    current_organization.blank? ||
      !current_organization.closed?
  end

  def unicity_constraint_violated?
    return false unless authorization_definition.unique

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    return false unless current_organization

    current_organization
      .active_authorization_requests
      .exists?(type: authorization_request_class.to_s)
  end
end
