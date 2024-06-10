class Instruction::AuthorizationRequestsController < InstructionController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  before_action :extract_authorization_request, except: [:index]
  before_action :redirect_to_searched_authorization_request, only: [:index]

  def index
    base_relation = policy_scope([:instruction, AuthorizationRequest]).includes([:organization]).not_archived

    base_relation = base_relation.none if search_terms_is_a_possible_id?

    @q = base_relation.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @authorization_requests = @q.result(distinct: true).page(params[:page])
  end

  def show
    authorize [:instruction, @authorization_request]

    render 'show', layout: 'instruction/authorization_request'
  end

  private

  def redirect_to_searched_authorization_request
    return unless search_terms_is_a_possible_id?

    potential_authorization_request = AuthorizationRequest.find_by(id: params[:q][:within_data_or_organization_siret_or_applicant_email_or_applicant_family_name_cont].to_i)

    return unless potential_authorization_request

    authorize [:instruction, potential_authorization_request], :show?

    redirect_to instruction_authorization_request_path(potential_authorization_request)
  rescue Pundit::NotAuthorizedError
    nil
  end

  def search_terms_is_a_possible_id?
    return false if params[:q].blank?

    main_search_input = params[:q][:within_data_or_organization_siret_or_applicant_email_or_applicant_family_name_cont]

    return false if main_search_input.blank?

    /^\s*\d{1,10}\s*$/.match?(main_search_input)
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id]).decorate
  end
end
