class DashboardFacade
  attr_reader :user, :search_query, :subdomain_types

  def initialize(user, search_query, subdomain_types: nil)
    @user = user
    @search_query = search_query
    @subdomain_types = subdomain_types
  end

  def demandes_data(policy_scope)
    search_builder = DemandesHabilitationsSearchEngineBuilder.new(user, { search_query: search_query }, subdomain_types: subdomain_types)
    demandes = search_builder.build_authorization_requests_relation(policy_scope)

    {
      highlighted_categories: {
        changes_requested: demandes.changes_requested,
      },
      categories: {
        pending: demandes.in_instructions,
        draft: demandes.drafts,
        refused: demandes.refused,
      },
      search_engine: search_builder.search_engine
    }
  end

  def habilitations_data(policy_scope)
    search_builder = DemandesHabilitationsSearchEngineBuilder.new(user, { search_query: search_query }, subdomain_types: subdomain_types)
    habilitations = search_builder.build_authorizations_relation(policy_scope)

    {
      highlighted_categories: {},
      categories: {
        active: habilitations.where(state: :active),
        revoked: habilitations.where(state: :revoked),
      },
      search_engine: search_builder.search_engine
    }
  end
end
