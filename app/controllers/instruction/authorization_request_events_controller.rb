class Instruction::AuthorizationRequestEventsController < Instruction::AuthorizationRequestsController
  before_action :extract_authorization_request

  def index
    authorize [:instruction, @authorization_request], :show?

    @events = @authorization_request.events.includes(%i[user entity]).order(created_at: :desc).decorate
  end

  private

  def layout_name
    'instruction/authorization_request'
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end
end
