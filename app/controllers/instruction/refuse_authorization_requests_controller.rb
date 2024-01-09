class Instruction::RefuseAuthorizationRequestsController < Instruction::AuthorizationRequestsController
  def new
    @denial_of_authorization = @authorization_request.denials.build
  end

  def create
    organizer = RefuseAuthorizationRequest.call(denial_of_authorization_params:, authorization_request: @authorization_request, user: current_user)

    @denial_of_authorization = organizer.denial_of_authorization

    if organizer.success?
      success_message(title: t('.success', name: organizer.authorization_request.name))

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

    authorize [:instruction, @authorization_request], :refuse?
  end
end
