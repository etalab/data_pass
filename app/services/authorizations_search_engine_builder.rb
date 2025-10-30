class AuthorizationsSearchEngineBuilder < AbstractSearchEngineBuilder
  def build_relation(policy_scope)
    base_items = policy_scope
      .includes(:request, :applicant, :organization, request: %i[organization])
      .order(created_at: :desc)

    mentions_items = AuthorizationAndRequestsMentionsQuery
      .new(user)
      .perform(Authorization.all)

    base_items = base_items.or(mentions_items)
    build_search_engine(base_items)
  end

  private

  def filter_by_applicant(base_items)
    base_items.joins(:request).where(authorization_requests: { applicant: user, organization: user.current_organization })
  end

  def filter_by_contact(base_items)
    AuthorizationAndRequestsMentionsQuery
      .new(user)
      .perform(base_items)
      .where.not(applicant: user)
  end

  def filter_by_organization(base_items)
    return base_items.none unless user.current_organization_verified?

    base_items.joins(:request)
      .where(authorization_requests: { organization: user.current_organization })
  end
end
