module CommonAuthorizationModelsPolicies
  protected

  def authorization_definition
    fail NoImplementedError
  end

  private

  def feature_enabled?(name)
    authorization_definition.feature?(name)
  end

  def same_current_organization?
    current_organization.present? &&
      record.organization.id == current_organization.id
  end

  def same_user_and_organization?
    record.applicant_id == user.id &&
      same_current_organization?
  end
end
