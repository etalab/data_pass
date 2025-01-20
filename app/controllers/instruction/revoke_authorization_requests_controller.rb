class Instruction::RevokeAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_revocation

  def new
    @revocation_of_authorization = @authorization_request.revocations.build
  end

  def create
    organizer = RevokeAuthorizationRequest.call(revocation_of_authorization_params:, authorization_request: @authorization_request, user: current_user)

    @revocation_of_authorization = organizer.revocation_of_authorization

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.revoke_authorization_requests.create')

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def revocation_of_authorization_params
    params.expect(
      revocation_of_authorization: [:reason],
    )
  end

  def authorize_authorization_request_revocation
    authorize [:instruction, @authorization_request], :revoke?
  end
end
