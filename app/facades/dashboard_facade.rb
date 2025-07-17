class DashboardFacade
  attr_reader :user, :params, :subdomain_types

  def initialize(user, params, subdomain_types: nil)
    @user = user
    @params = params
    @subdomain_types = subdomain_types
  end

  def demandes_data(policy_scope)
    search_builder = DemandesHabilitationsSearchEngineBuilder.new(user, params, subdomain_types: subdomain_types)
    items = search_builder.build_authorization_requests_relation(policy_scope)

    {
      highlighted_categories: {
        changes_requested: items.changes_requested,
      },
      categories: {
        pending: items.in_instructions,
        draft: items.drafts,
        refused: items.refused,
      },
      search_engine: search_builder.search_engine
    }
  end

  def habilitations_data(policy_scope)
    search_builder = DemandesHabilitationsSearchEngineBuilder.new(user, params, subdomain_types: subdomain_types)
    items = search_builder.build_authorizations_relation(policy_scope)

    {
      highlighted_categories: {},
      categories: {
        active: items.where(state: :active),
        revoked: items.where(state: :revoked),
      },
      search_engine: search_builder.search_engine
    }
  end
end
