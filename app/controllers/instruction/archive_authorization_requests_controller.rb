class Instruction::ArchiveAuthorizationRequestsController < Instruction::AuthorizationRequestsController
  before_action :extract_authorization_request

  def new
    render 'archive_authorization_requests/new'
  end

  def create
    organizer = ArchiveAuthorizationRequest.call(authorization_request: @authorization_request, user: current_user)

    if organizer.success?
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])

    authorize [:instruction, @authorization_request], :archive?
  end
end
