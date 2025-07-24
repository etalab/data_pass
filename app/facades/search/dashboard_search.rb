class Search::DashboardSearch
  attr_reader :search_engine, :results, :user, :subdomain_types

  def initialize(user:, params:, subdomain_types: nil, scope:)
    @user = user
    @params = params
    @subdomain_types = subdomain_types
    @scope = scope

    build_search
  end

  def paginated_results
    results.page(params[:page])
  end

  delegate :count, to: :results

  def self.search_terms_is_a_possible_id?(params)
    return false if params[:search_query].blank?

    main_search_input = params[:search_query]['within_data_or_id_cont']

    return false if main_search_input.blank?

    /^\s*\d{1,10}\s*$/.match?(main_search_input)
  end

  private

  attr_reader :params, :scope

  def build_search
    filtered_items = apply_user_relationship_filter
    @search_engine = build_search_engine(filtered_items)
    @results = build_search_results
  end

  def base_relation
    @aase_relation ||= scope.includes(includes_associations).order(default_sort)
  end

  def includes_associations
    raise NotImplementedError, 'Subclasses must implement #includes_associations'
  end

  def default_sort
    { created_at: :desc }
  end

  def apply_user_relationship_filter
    user_relationship = params[:search_query]&.dig('user_relationship_eq')

    case user_relationship
    when 'contact'
      filter_by_contact
    when 'organization'
      filter_by_organization
    else
      filter_by_applicant
    end
  end

  def filter_by_applicant
    raise NotImplementedError, 'Subclasses must implement #filter_by_applicant'
  end

  def filter_by_contact
    raise NotImplementedError, 'Subclasses must implement #filter_by_contact'
  end

  def filter_by_organization
    raise NotImplementedError, 'Subclasses must implement #filter_by_organization'
  end

  def build_search_engine(base_items)
    excluded_params = %w[within_data_or_id_cont user_relationship_eq]
    filtered_items = apply_text_search_if_present(base_items)
    
    search = filtered_items.ransack(params[:search_query]&.except(*excluded_params))
    search.sorts = default_sort.to_a.map { |k, v| "#{k} #{v}" }.join(', ') if search.sorts.empty?
    search
  end

  def build_search_results
    search_engine.result(distinct: true).except(:order).order("#{search_engine.sorts.first.name} #{search_engine.sorts.first.dir} NULLS LAST")
  end

  def apply_text_search_if_present(base_items)
    if params[:search_query]&.dig('within_data_or_id_cont').present?
      search_term = params[:search_query]['within_data_or_id_cont']
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

  def search_terms_is_a_possible_id?
    self.class.search_terms_is_a_possible_id?(params)
  end
end
