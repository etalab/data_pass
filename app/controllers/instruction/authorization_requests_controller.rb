class Instruction::AuthorizationRequestsController < InstructionController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  before_action :extract_authorization_request, except: [:index]
  before_action :redirect_to_searched_authorization_request, only: [:index]

  def index
    @q = policy_scope([:instruction, AuthorizationRequest]).includes([:organization]).not_archived.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @authorization_requests = @q.result(distinct: true).page(params[:page])
  end

  def show
    authorize [:instruction, @authorization_request]

    render 'show', layout: 'instruction/authorization_request'
  end

  private

  def redirect_to_searched_authorization_request
    return if params[:q].blank?

    main_search_input = params[:q][:within_data_or_organization_siret_cont]

    return if main_search_input.blank?
    return unless /\s*\d+\s*/.match?(main_search_input)

    potential_authorization_request = AuthorizationRequest.find_by(id: main_search_input.to_i)

    return unless potential_authorization_request

    authorize [:instruction, potential_authorization_request], :show?

    redirect_to instruction_authorization_request_path(potential_authorization_request)
  rescue Pundit::NotAuthorizedError
    nil
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id]).decorate
  end
end
