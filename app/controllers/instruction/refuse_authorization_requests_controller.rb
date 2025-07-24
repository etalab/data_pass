class Instruction::RefuseAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_refusal

  def new
    @denial_of_authorization = @authorization_request.denials.build
  end

  def create
    organizer = RefuseAuthorizationRequest.call(denial_of_authorization_params:, authorization_request: @authorization_request, user: current_user)

    @denial_of_authorization = organizer.denial_of_authorization

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.refuse_authorization_requests.create')

      redirect_to instruction_dashboard_show_path(id: 'demandes'),
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def denial_of_authorization_params
    params.expect(
      denial_of_authorization: [:reason],
    )
  end

  def authorize_authorization_request_refusal
    authorize [:instruction, @authorization_request], :refuse?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
