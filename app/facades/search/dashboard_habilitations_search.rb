class Search::DashboardHabilitationsSearch < Search::DashboardSearch
  private

  def base_relation
    base_scope = super
    # Apply the mentions OR logic at the base level like the original
    base_scope.or(authorization_mentions_query(Authorization.all))
  end

  def includes_associations
    [:request, :applicant]
  end

  def default_sort
    { 'authorizations.created_at': :desc }
  end

  def filter_by_applicant
    base_relation.joins(:request).where(authorization_requests: { applicant: user, organization: user.current_organization })
  end

  def filter_by_contact
    authorization_mentions_query(base_relation).where.not(applicant: user)
  end

  def filter_by_organization
    base_relation.joins(:request).where(authorization_requests: { organization: user.current_organization })
  end
end
