class AbstractSearchEngineBuilder
  attr_reader :search_engine, :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def build_search_engine(base_items)
    filtered_items = apply_user_relationship_filter(base_items)
    apply_search_and_build_engine(filtered_items)
  end

  private

  def apply_user_relationship_filter(base_items)
    user_relationship = params[:search_query]&.dig(:user_relationship_eq)

    case user_relationship
    when 'contact'
      filter_by_contact(base_items)
    when 'organization'
      return base_items.none unless user.current_organization_verified?

      filter_by_organization(base_items)
    when 'applicant'
      filter_by_applicant(base_items)
    else
      base_items
    end
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

  def filter_by_applicant(_base_items)
    raise NotImplementedError, 'Subclasses must implement #filter_by_applicant'
  end

  def filter_by_contact(_base_items)
    raise NotImplementedError, 'Subclasses must implement #filter_by_contact'
  end

  def filter_by_organization(_base_items)
    raise NotImplementedError, 'Subclasses must implement #filter_by_organization'
  end
end
