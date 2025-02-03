class Instruction::ApproveAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_approval

  def new; end

  def create
    organizer = ApproveAuthorizationRequest.call(authorization_request: @authorization_request, user: current_user)

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.approve_authorization_requests.create')

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def authorize_authorization_request_approval
    authorize [:instruction, @authorization_request], :approve?
  end
end
