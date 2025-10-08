class DashboardFacade
  attr_reader :user, :search_query, :subdomain_types

  def initialize(user, search_query, subdomain_types: nil)
    @user = user
    @search_query = search_query
    @subdomain_types = subdomain_types
  end

  def demandes_data(policy_scope)
    builder = search_builder({ search_query: search_query })
    demandes = builder.build_authorization_requests_relation(policy_scope)

    {
      highlighted_categories: {
        changes_requested: demandes.changes_requested,
      },
      categories: {
        pending: demandes.in_instructions,
        draft: demandes.drafts,
        refused: demandes.refused,
      },
      search_engine: builder.search_engine
    }
  end

  def habilitations_data(policy_scope)
    builder = search_builder({ search_query: search_query })
    habilitations = builder.build_authorizations_relation(policy_scope)

    {
      highlighted_categories: {},
      categories: {
        active: habilitations.where(state: :active),
        revoked: habilitations.where(state: :revoked),
      },
      search_engine: builder.search_engine
    }
  end

  def show_demandes_filters?(policy_scope)
    count_all_demandes(policy_scope) > 9
  end

  def show_habilitations_filters?(policy_scope)
    count_all_habilitations(policy_scope) > 9
  end

  private

  def count_all_demandes(policy_scope)
    items = all_accessible_authorization_requests(policy_scope)
    [
      items.changes_requested,
      items.in_instructions,
      items.drafts,
      items.refused
    ].sum(&:count)
  end

  def count_all_habilitations(policy_scope)
    items = all_accessible_authorizations(policy_scope)
    [
      items.where(state: :active),
      items.where(state: :revoked)
    ].sum(&:count)
  end

  def all_accessible_authorization_requests(policy_scope)
    org_items = policy_scope
      .includes(:applicant, :authorizations)
      .not_archived
      .order(created_at: :desc)

    mentions_items = AuthorizationAndRequestsMentionsQuery.new(user).perform(AuthorizationRequest.all)

    org_items.or(mentions_items)
  end

  def all_accessible_authorizations(policy_scope)
    org_items = policy_scope
      .includes(:request, :applicant)
      .order(created_at: :desc)

    mentions_items = AuthorizationAndRequestsMentionsQuery.new(user).perform(Authorization.all)

    org_items.or(mentions_items)
  end

  def search_builder(params)
    DemandesHabilitationsSearchEngineBuilder.new(user, params, subdomain_types: subdomain_types)
  end
end
