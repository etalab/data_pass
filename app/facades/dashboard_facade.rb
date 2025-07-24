class DashboardFacade
  attr_reader :tabs, :items, :search_engine, :partial

  Tab = Data.define(:id, :path, :count)

  def initialize(search_object:)
    @search_object = search_object
    build_facade
  end

  # Legacy methods for backward compatibility - these will be replaced by categories/highlighted_categories
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

  # New unified interface methods
  def categories
    raise NotImplementedError, 'Subclasses must implement #categories'
  end

  def highlighted_categories
    raise NotImplementedError, 'Subclasses must implement #highlighted_categories'
  end

  private

  attr_reader :search_object

  def build_facade
    @search_engine = search_object.search_engine
    @items = search_object.paginated_results
    @tabs = build_tabs
    @partial = partial_name
  end

  def build_tabs
    [
      Tab.new('demandes', dashboard_show_path(id: 'demandes'), demandes_count),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations'), habilitations_count),
    ]
  end

  def partial_name
    raise NotImplementedError, 'Subclasses must implement #partial_name'
  end

  def demandes_count
    raise NotImplementedError, 'Subclasses must implement #demandes_count'
  end

  def habilitations_count
    raise NotImplementedError, 'Subclasses must implement #habilitations_count'
  end

  def dashboard_show_path(id:)
    Rails.application.routes.url_helpers.dashboard_show_path(id: id)
  end

  # Legacy getters for backward compatibility
  def user
    @user
  end

  def search_query
    @search_query
  end

  def subdomain_types
    @subdomain_types
  end
end
