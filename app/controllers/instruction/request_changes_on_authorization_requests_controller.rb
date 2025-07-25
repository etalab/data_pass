class Instruction::RequestChangesOnAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_changes_request

  def new
    @instructor_modification_request = @authorization_request.modification_requests.build

    AffectDefaultReasonToInstructionModificationRequest.call(instructor_modification_request: @instructor_modification_request)
  end

  def create
    organizer = RequestChangesOnAuthorizationRequest.call(instructor_modification_request_params:, authorization_request: @authorization_request, user: current_user)

    @instructor_modification_request = organizer.instructor_modification_request

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.request_changes_on_authorization_requests.create')

      redirect_to instruction_dashboard_show_path(id: 'demandes'),
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def instructor_modification_request_params
    params.expect(
      instructor_modification_request: [:reason],
    )
  end

  def authorize_authorization_request_changes_request
    authorize [:instruction, @authorization_request], :request_changes?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
