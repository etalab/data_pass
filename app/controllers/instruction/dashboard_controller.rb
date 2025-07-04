class Instruction::DashboardController < Instruction::AbstractAuthorizationRequestsController
  before_action :redirect_to_searched_record
  before_action :save_or_load_search_params

  skip_before_action :extract_authorization_request

  Tab = Data.define(:id, :path, :count)

  def show # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    case params[:id]
    when 'habilitations'
      base_relation = policy_scope([:instruction, Authorization]).includes([:organization])
      base_relation = base_relation.none if search_terms_is_a_possible_id?

      @search_engine = base_relation.ransack(params[:search_query])
      @search_engine.sorts = 'created_at desc' if @search_engine.sorts.empty?

      @authorizations = build_search_engine_results_with_order_which_puts_null_as_last
      @tabs = [
        Tab.new('demandes', instruction_dashboard_show_path(id: 'demandes'), 0),
        Tab.new('habilitations', instruction_dashboard_show_path(id: 'habilitations'), @authorizations.count),
      ]
      @partial = 'authorizations'
      @items = @authorizations.page(params[:page])
    when 'demandes'
      base_relation = policy_scope([:instruction, AuthorizationRequest]).includes([:organization])
      base_relation = base_relation.not_validated
      base_relation = base_relation.not_archived if params.dig('search_query', 'state_eq').blank?
      base_relation = base_relation.none if search_terms_is_a_possible_id?

      @search_engine = base_relation.ransack(params[:search_query])
      @search_engine.sorts = 'last_submitted_at desc' if @search_engine.sorts.empty?

      @authorization_requests = build_search_engine_results_with_order_which_puts_null_as_last
      @tabs = [
        Tab.new('demandes', instruction_dashboard_show_path(id: 'demandes'), @authorization_requests.count),
        Tab.new('habilitations', instruction_dashboard_show_path(id: 'habilitations'), 0),
      ]
      @partial = 'authorization_requests'
      @items = @authorization_requests.page(params[:page])
    else
      redirect_to(instruction_dashboard_show_path(id: 'demandes')) and return
    end
  end

  private

  def build_search_engine_results_with_order_which_puts_null_as_last
    @search_engine.result(distinct: true).except(:order).order("#{@search_engine.sorts.first.name} #{@search_engine.sorts.first.dir} NULLS LAST")
  end

  def find_searched_record
    case params[:id]
    when 'demandes'
      AuthorizationRequest.find_by(id: params[:search_query][main_search_input_key])
    when 'habilitations'
      Authorization.find_by(id: params[:search_query][main_search_input_key])
    end
  end

  def load_search_params
    params[:search_query] = JSON.parse(cookies[search_key] || '{}') if params[:search_query].blank?
  end

  def main_search_input_key
    'within_data_or_organization_name_or_organization_legal_entity_id_or_applicant_email_or_applicant_family_name_cont'
  end

  def redirect_to_searched_record
    return unless search_terms_is_a_possible_id?

    candidate = find_searched_record
    return unless candidate

    authorize [:instruction, candidate], :show?

    redirect_to search_record_path(candidate)
  rescue Pundit::NotAuthorizedError
    nil
  end

  def save_or_load_search_params
    save_search_params
    load_search_params
  end

  def save_search_params
    cookies[search_key] = { value: params[:search_query].to_json, expires: 1.month.from_now } if params[:search_query].present?
  end

  def search_key
    :"#{controller_name}_#{action_name}_#{params[:id]}_search"
  end

  def search_record_path(record)
    case params[:id]
    when 'demandes'
      instruction_authorization_request_path(record)
    when 'habilitations'
      authorization_path(record)
    end
  end

  def search_terms_is_a_possible_id?
    return false if params[:search_query].blank?

    main_search_input = params[:search_query][main_search_input_key]

    return false if main_search_input.blank?

    /^\s*\d{1,10}\s*$/.match?(main_search_input)
  end
end
