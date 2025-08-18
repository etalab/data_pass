class Search::DashboardDemandesSearch < Search::DashboardSearch
  private

  def base_relation
    base_scope = super.not_archived
    # Apply the mentions OR logic at the base level like the original
    base_scope.or(authorization_request_mentions_query(AuthorizationRequest.all))
  end

  def includes_associations
    [:applicant, :authorizations]
  end

  def filter_by_applicant
    base_relation.where(applicant: user, organization: user.current_organization)
  end

  def filter_by_contact
    authorization_request_mentions_query(base_relation).where.not(applicant: user)
  end

  def filter_by_organization
    base_relation.where(organization: user.current_organization)
  end
end
