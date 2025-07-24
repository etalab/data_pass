class Instruction::Search::DashboardSearch
  attr_reader :search_engine, :results

  def initialize(params:, scope:)
    @params = params
    @scope = scope

    build_search
  end

  def paginated_results
    results.page(params[:page])
  end

  delegate :count, to: :results

  def self.search_terms_is_a_possible_id?(params)
    return false if params[:search_query].blank?

    main_search_input = params[:search_query][key]

    return false if main_search_input.blank?

    /^\s*\d{1,10}\s*$/.match?(main_search_input)
  end

  def self.key
    'within_data_or_organization_name_or_organization_legal_entity_id_or_applicant_email_or_applicant_family_name_cont'
  end

  private

  attr_reader :params, :scope

  def build_search
    @search_engine = build_search_engine
    @results = build_search_results
  end

  def base_relation
    scope.includes(includes_associations)
  end

  def includes_associations
    [:organization]
  end

  def build_search_engine
    search = base_relation.ransack(params[:search_query])
    search.sorts = default_sort if search.sorts.empty?
    search
  end

  def build_search_results
    search_engine.result(distinct: true).except(:order).order("#{search_engine.sorts.first.name} #{search_engine.sorts.first.dir} NULLS LAST")
  end

  def default_sort
    raise NotImplementedError, 'Subclasses must implement #default_sort'
  end

  def search_terms_is_a_possible_id?
    self.class.search_terms_is_a_possible_id?(params)
  end
end
