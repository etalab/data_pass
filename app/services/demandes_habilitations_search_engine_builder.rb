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

  def build_authorization_requests_relation(policy_scope)
    base_items = policy_scope
      .includes(:applicant, :organization, authorizations: %i[organization])
      .not_archived
      .order(created_at: :desc)

    base_items = base_items.or(authorization_request_mentions_query(AuthorizationRequest.all))
    build_search_engine(base_items)
  end

  def build_authorizations_relation(policy_scope)
    base_items = policy_scope
      .includes(:request, :applicant, :organization, request: %i[organization])
      .order(created_at: :desc)

    base_items = base_items.or(authorization_mentions_query(Authorization.all))
    build_search_engine(base_items)
  end

  private

  def apply_user_relationship_filter(base_items)
    user_relationship = params[:search_query]&.dig(:user_relationship_eq)

    case user_relationship
    when 'contact'
      filter_by_contact(base_items)
    when 'organization'
      filter_by_organization(base_items)
    when 'applicant'
      filter_by_applicant(base_items)
    else
      base_items
    end
  end

  def filter_by_applicant(base_items)
    if authorization_request_relation?(base_items)
      base_items.where(applicant: user, organization: user.current_organization)
    else
      base_items.joins(:request).where(authorization_requests: { applicant: user, organization: user.current_organization })
    end
  end

  def filter_by_contact(base_items)
    if authorization_request_relation?(base_items)
      authorization_request_mentions_query(base_items)
        .where.not(applicant: user)
    else
      authorization_mentions_query(base_items)
        .where.not(applicant: user)
    end
  end

  def filter_by_organization(base_items)
    if authorization_request_relation?(base_items)
      base_items.where(organization: user.current_organization)
    else
      base_items.joins(:request)
        .where(authorization_requests: { organization: user.current_organization })
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

  def authorization_mentions_query(base_items)
    AuthorizationAndRequestsMentionsQuery.new(user).perform(base_items)
  end

  def authorization_request_mentions_query(base_items)
    AuthorizationAndRequestsMentionsQuery.new(user).perform(base_items)
  end
end
