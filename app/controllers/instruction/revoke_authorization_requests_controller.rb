class Instruction::RevokeAuthorizationRequestsController < Instruction::AuthorizationRequestsController
  before_action :authorize_authorization_request_revocation

  def new
    @denial_of_authorization = @authorization_request.denials.build
  end

  def create
    organizer = RevokeAuthorizationRequest.call(denial_of_authorization_params:, authorization_request: @authorization_request, user: current_user)

    @denial_of_authorization = organizer.denial_of_authorization

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.revoke_authorization_requests.create')

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def denial_of_authorization_params
    params.require(:denial_of_authorization).permit(
      :reason,
    )
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def authorize_authorization_request_revocation
    authorize [:instruction, @authorization_request], :revoke?
  end
end
