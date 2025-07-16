class DemandesHabilitationsSearchEngineBuilder
  attr_reader :search_engine, :user, :params, :subdomain_types

  def initialize(user, params, subdomain_types: nil)
    @user = user
    @params = params
    @subdomain_types = subdomain_types
  end

  def build_search_engine(base_items)
    filtered_items = apply_user_relationship_filter(base_items)
    apply_search_and_build_engine(filtered_items)
  end

  def build_authorization_requests_relation(policy_scope_callback)
    base_items = policy_scope_callback.call(authorization_requests_base_relation)
      .includes(:applicant, :authorizations)
      .not_archived
      .order(created_at: :desc)
      .or(authorization_request_mentions_query(authorization_requests_base_relation))

    build_search_engine(base_items)
  end

  def build_authorizations_relation(policy_scope_callback)
    base_items = policy_scope_callback.call(authorizations_base_relation)
      .includes(:request, :applicant)
      .order(created_at: :desc)
      .or(authorization_mentions_query)

    build_search_engine(base_items)
  end

  private

  def apply_user_relationship_filter(base_items)
    user_relationship = params[:search_query]&.dig(:user_relationship_eq)
    return base_items if user_relationship.blank?

    case user_relationship
    when 'applicant'
      base_items.where(applicant: user)
    when 'contact'
      filter_by_contact(base_items)
    when 'organization'
      base_items.where.not(applicant: user)
    else
      base_items
    end
  end

  def filter_by_contact(base_items)
    if authorization_request_relation?(base_items)
      authorization_request_mentions_query(base_items)
        .where.not(applicant: user)
    else
      authorization_mentions_query
        .where.not(applicant: user)
    end
  end

  def authorization_request_relation?(base_items)
    base_items.model == AuthorizationRequest
  end

  def apply_search_and_build_engine(base_items)
    excluded_params = %i[within_data_or_id_cont user_relationship_eq]

    base_items = apply_text_search_if_present(base_items)

    @search_engine = base_items.ransack(params[:search_query]&.except(*excluded_params))
    @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?
    @search_engine.result
  end

  def apply_text_search_if_present(base_items)
    if params[:search_query]&.dig(:within_data_or_id_cont).present?
      search_term = params[:search_query][:within_data_or_id_cont]
      base_items.search_by_query(search_term)
    else
      base_items
    end
  end

  def authorization_mentions_query
    Authorization.where("EXISTS (
        select 1
        from each(authorizations.data) as kv
        where kv.key like '%_email' and kv.value = ?
      )", user.email)
  end

  def authorization_request_mentions_query(base_items)
    AuthorizationRequestsMentionsQuery.new(user).perform(base_items)
  end

  def authorization_requests_base_relation
    base_relation = AuthorizationRequest
      .joins('left join authorizations on authorizations.request_id = authorization_requests.id')
      .select('authorization_requests.*, count(authorizations.id) as authorizations_count')
      .group('authorization_requests.id')

    if subdomain_types.present?
      base_relation.where(type: subdomain_types)
    else
      base_relation
    end
  end

  def authorizations_base_relation
    Authorization.joins(request: :organization).where(authorization_requests: { organization: user.organizations })
  end
end
