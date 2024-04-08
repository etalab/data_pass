class Instruction::AuthorizationRequestsController < InstructionController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  before_action :extract_authorization_request, except: [:index]

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

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id]).decorate
  end
end
