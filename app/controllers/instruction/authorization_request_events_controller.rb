class Instruction::AuthorizationRequestEventsController < Instruction::AuthorizationRequestsController
  layout 'instruction/authorization_request'

  before_action :extract_authorization_request

  def index
    authorize [:instruction, @authorization_request], :show?

    @events = @authorization_request.events.includes(%i[user entity]).order(created_at: :desc)
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])

    authorize [:instruction, @authorization_request], :show?
  end
end
