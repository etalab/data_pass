class Instruction::ApproveAuthorizationRequestsController < Instruction::AuthorizationRequestsController
  def new; end

  def create
    organizer = ApproveAuthorizationRequest.call(authorization_request: @authorization_request)

    if organizer.success?
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render_show
    end
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])

    authorize [:instruction, @authorization_request], :approve?
  end
end
