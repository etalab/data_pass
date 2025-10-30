class AuthorizationRequestsSearchEngineBuilder < AbstractSearchEngineBuilder
  attr_reader :subdomain_types

  def initialize(user, params, subdomain_types: nil)
    super(user, params)
    @subdomain_types = subdomain_types
  end

  def build_relation(policy_scope)
    base_items = policy_scope
      .includes(:applicant, :organization, authorizations: %i[organization])
      .not_archived
      .order(created_at: :desc)

    base_items = base_items.where(type: subdomain_types) if subdomain_types.present?

    mentions_items = AuthorizationAndRequestsMentionsQuery
      .new(user)
      .perform(AuthorizationRequest.all)

    base_items = base_items.or(mentions_items)
    build_search_engine(base_items)
  end

  private

  def filter_by_applicant(base_items)
    base_items.where(applicant: user, organization: user.current_organization)
  end

  def filter_by_contact(base_items)
    AuthorizationAndRequestsMentionsQuery
      .new(user)
      .perform(base_items)
  end

  def filter_by_organization(base_items)
    return base_items.none unless user.current_organization_verified?

    base_items.where(organization: user.current_organization)
  end
end
