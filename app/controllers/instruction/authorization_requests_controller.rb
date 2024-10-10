class Instruction::AuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :redirect_to_searched_authorization_request, only: [:index]
  before_action :save_or_load_search_params, only: [:index]

  skip_before_action :extract_authorization_request, only: :index

  def index
    base_relation = policy_scope([:instruction, AuthorizationRequest]).includes([:organization]).not_archived

    base_relation = base_relation.none if search_terms_is_a_possible_id?

    @search_engine = base_relation.ransack(params[:search_query])
    @search_engine.sorts = 'last_submitted_at desc' if @search_engine.sorts.empty?

    @authorization_requests = build_search_engine_results_with_order_which_puts_null_as_last.page(params[:page])
  end

  def show
    authorize [:instruction, @authorization_request]

    render 'show', layout: 'instruction/authorization_request'
  end

  private

  def redirect_to_searched_authorization_request
    return unless search_terms_is_a_possible_id?

    potential_authorization_request = AuthorizationRequest.find_by(id: params[:search_query][:within_data_or_organization_raison_sociale_or_organization_siret_or_applicant_email_or_applicant_family_name_cont].to_i)

    return unless potential_authorization_request

    authorize [:instruction, potential_authorization_request], :show?

    redirect_to instruction_authorization_request_path(potential_authorization_request)
  rescue Pundit::NotAuthorizedError
    nil
  end

  def search_terms_is_a_possible_id?
    return false if params[:search_query].blank?

    main_search_input = params[:search_query][:within_data_or_organization_raison_sociale_or_organization_siret_or_applicant_email_or_applicant_family_name_cont]

    return false if main_search_input.blank?

    /^\s*\d{1,10}\s*$/.match?(main_search_input)
  end

  def build_search_engine_results_with_order_which_puts_null_as_last
    @search_engine.result(distinct: true).except(:order).order("#{@search_engine.sorts.first.name} #{@search_engine.sorts.first.dir} NULLS LAST")
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id]).decorate
  end

  def save_or_load_search_params
    session[search_key] = params[:search_query] if params[:search_query].present?
    params[:search_query] = session[search_key] if params[:search_query].blank?
  end

  def search_key
    :"#{controller_name}_#{action_name}_search"
  end
end
