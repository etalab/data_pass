class Instruction::RequestChangesOnAuthorizationRequestsController < Instruction::AuthorizationRequestsController
  def new
    @instructor_modification_request = @authorization_request.modification_requests.build
  end

  def create
    organizer = RequestChangesOnAuthorizationRequest.call(instructor_modification_request_params:, authorization_request: @authorization_request, user: current_user)

    @instructor_modification_request = organizer.instructor_modification_request

    if organizer.success?
      success_message(title: t('.success', name: organizer.authorization_request.name))

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def instructor_modification_request_params
    params.require(:instructor_modification_request).permit(
      :reason,
    )
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])

    authorize [:instruction, @authorization_request], :request_changes?
  end
end
