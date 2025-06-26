class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  Tab = Data.define(:id, :path)

  def show # rubocop:disable Metrics/AbcSize
    @tabs = [
      Tab.new('demandes', dashboard_show_path(id: 'demandes', **request.query_parameters)),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations', **request.query_parameters)),
    ]

    case params[:id]
    when 'demandes'
      items = policy_scope(base_relation).not_archived.order(created_at: :desc).or(authorization_request_mentions_query)
      @highlighted_categories = {
        changes_requested: items.changes_requested,
      }
      @categories = {
        pending: items.in_instructions,
        draft: items.drafts,
        refused: items.refused,
      }
    when 'habilitations'
      items = policy_scope(base_authorization_relation).order(created_at: :desc).or(authorization_mentions_query)

      @highlighted_categories = {}
      @categories = {
        active: items.where(state: :active),
        revoked: items.where(state: :revoked),
      }
    else
      redirect_to(dashboard_show_path(id: 'demandes')) and return
    end
  end

  private

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
