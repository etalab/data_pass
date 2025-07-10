class DashboardController < AuthenticatedUserController
  include SubdomainsHelper

  def index
    redirect_to dashboard_show_path(id: 'demandes')
  end

  Tab = Data.define(:id, :path)

  def show
    @tabs = [
      Tab.new('demandes', dashboard_show_path(id: 'demandes', **request.query_parameters)),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations', **request.query_parameters)),
    ]

    case params[:id]
    when 'demandes'
      handle_demandes_tab
    when 'habilitations'
      handle_habilitations_tab
    else
      redirect_to(dashboard_show_path(id: 'demandes')) and return
    end
  end

  private

  def handle_demandes_tab
    base_items = policy_scope(base_relation)
      .includes(:applicant, :authorizations)
      .not_archived
      .order(created_at: :desc)
      .or(authorization_request_mentions_query)

    base_items = apply_user_relationship_filter(base_items, :demandes)
    items = apply_search_and_build_engine(base_items)

    @highlighted_categories = {
      changes_requested: items.changes_requested,
    }
    @categories = {
      pending: items.in_instructions,
      draft: items.drafts,
      refused: items.refused,
    }
  end

  def handle_habilitations_tab
    base_items = policy_scope(base_authorization_relation)
      .includes(:request, :applicant)
      .order(created_at: :desc)
      .or(authorization_mentions_query)

    base_items = apply_user_relationship_filter(base_items, :habilitations)
    items = apply_search_and_build_engine(base_items)

    @highlighted_categories = {}
    @categories = {
      active: items.where(state: :active),
      revoked: items.where(state: :revoked),
    }
  end

  def apply_user_relationship_filter(base_items, tab_type) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    user_relationship = params[:search_query]&.dig(:user_relationship_eq)
    return base_items if user_relationship.blank?

    case user_relationship
    when 'applicant'
      base_items.where(applicant: current_user)
    when 'contact'
      if tab_type == :demandes
        AuthorizationRequestsMentionsQuery.new(current_user).perform(base_items)
          .where.not(applicant: current_user)
      else
        authorization_mentions_query
          .where.not(applicant: current_user)
      end
    when 'organization'
      base_items.where.not(applicant: current_user)
    else
      base_items
    end
  end

  def apply_search_and_build_engine(base_items) # rubocop:disable Metrics/AbcSize
    excluded_params = %i[within_data_or_api_service_name_or_id_cont user_relationship_eq]

    if params[:search_query]&.dig(:within_data_or_api_service_name_or_id_cont).present?
      search_term = params[:search_query][:within_data_or_api_service_name_or_id_cont]
      base_items = base_items.search_by_query(search_term)
    end

    @search_engine = base_items.ransack(params[:search_query]&.except(*excluded_params))
    @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?
    @search_engine.result
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
