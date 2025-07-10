class DashboardFacade
  include SubdomainsHelper

  attr_reader :current_user, :params, :request

  Tab = Data.define(:id, :path)

  def initialize(current_user, params, request = nil)
    @current_user = current_user
    @params = params
    @request = request
  end

  def tabs
    [
      Tab.new('demandes', dashboard_show_path(id: 'demandes', **query_parameters)),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations', **query_parameters)),
    ]
  end

  def demandes_data(policy_scope_callback)
    base_items = policy_scope_callback.call(base_relation)
      .includes(:applicant, :authorizations)
      .not_archived
      .order(created_at: :desc)
      .or(authorization_request_mentions_query)

    search_builder = SearchEngineBuilder.new(current_user, params)
    items = search_builder.build_search_engine(base_items)

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

  def habilitations_data(policy_scope_callback)
    base_items = policy_scope_callback.call(base_authorization_relation)
      .includes(:request, :applicant)
      .order(created_at: :desc)
      .or(authorization_mentions_query)

    search_builder = SearchEngineBuilder.new(current_user, params)
    items = search_builder.build_search_engine(base_items)

    {
      highlighted_categories: {},
      categories: {
        active: items.where(state: :active),
        revoked: items.where(state: :revoked),
      },
      search_engine: search_builder.search_engine
    }
  end

  private

  def query_parameters
    request&.query_parameters || {}
  end

  def dashboard_show_path(options = {})
    Rails.application.routes.url_helpers.dashboard_show_path(options)
  end

  def authorization_mentions_query
    Authorization.where("EXISTS (
        select 1
        from each(authorizations.data) as kv
        where kv.key like '%_email' and kv.value = ?
      )", current_user.email)
  end

  def authorization_request_mentions_query
    AuthorizationRequestsMentionsQuery.new(current_user).perform(authorization_requests_relation)
  end

  def authorization_requests_relation
    if registered_subdomain?
      base_relation.where(type: registered_subdomain.authorization_request_types)
    else
      base_relation.all
    end
  end

  def base_relation
    AuthorizationRequest
      .joins('left join authorizations on authorizations.request_id = authorization_requests.id')
      .select('authorization_requests.*, count(authorizations.id) as authorizations_count')
      .group('authorization_requests.id')
  end

  def base_authorization_relation
    Authorization.joins(request: :organization).where(authorization_requests: { organization: current_user.organizations })
  end
end
