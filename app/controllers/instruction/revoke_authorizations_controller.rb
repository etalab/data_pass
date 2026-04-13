class Instruction::RevokeAuthorizationsController < InstructionController
  include AuthorizationRequestsFlashes

  before_action :extract_authorization
  before_action :authorize_authorization_revocation

  def new
    @revocation_of_authorization = @authorization.request.revocations.build
  end

  def create
    organizer = RevokeAuthorization.call(
      revocation_of_authorization_params:,
      authorization: @authorization,
      user: current_user
    )

    @revocation_of_authorization = organizer.revocation_of_authorization

    if organizer.success?
      success_message_for_authorization_request(
        @authorization.request,
        key: 'instruction.revoke_authorizations.create'
      )

      redirect_to authorization_path(@authorization),
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def extract_authorization
    @authorization = Authorization.find(params[:authorization_id])
  end

  def revocation_of_authorization_params
    params.expect(
      revocation_of_authorization: [:reason],
    )
  end

  def authorize_authorization_revocation
    authorize [:instruction, @authorization], :revoke?
  end

  def model_to_track_for_impersonation
    @authorization
  end
end
