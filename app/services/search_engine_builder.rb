class SearchEngineBuilder
  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end

  def build_search_engine(base_items)
    filtered_items = apply_user_relationship_filter(base_items)
    apply_search_and_build_engine(filtered_items)
  end

  attr_reader :search_engine

  private

  attr_reader :current_user, :params

  def apply_user_relationship_filter(base_items)
    user_relationship = params[:search_query]&.dig(:user_relationship_eq)
    return base_items if user_relationship.blank?

    case user_relationship
    when 'applicant'
      base_items.where(applicant: current_user)
    when 'contact'
      filter_by_contact(base_items)
    when 'organization'
      base_items.where.not(applicant: current_user)
    else
      base_items
    end
  end

  def filter_by_contact(base_items)
    if authorization_request_relation?(base_items)
      authorization_request_mentions_query(base_items)
        .where.not(applicant: current_user)
    else
      authorization_mentions_query
        .where.not(applicant: current_user)
    end
  end

  def authorization_request_relation?(base_items)
    base_items.model == AuthorizationRequest
  end

  def apply_search_and_build_engine(base_items)
    excluded_params = %i[within_data_or_api_service_name_or_id_cont user_relationship_eq]

    base_items = apply_text_search_if_present(base_items)

    @search_engine = base_items.ransack(params[:search_query]&.except(*excluded_params))
    @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?
    @search_engine.result
  end

  def apply_text_search_if_present(base_items)
    if params[:search_query]&.dig(:within_data_or_api_service_name_or_id_cont).present?
      search_term = params[:search_query][:within_data_or_api_service_name_or_id_cont]
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
      )", current_user.email)
  end

  def authorization_request_mentions_query(base_items)
    AuthorizationRequestsMentionsQuery.new(current_user).perform(base_items)
  end
end
