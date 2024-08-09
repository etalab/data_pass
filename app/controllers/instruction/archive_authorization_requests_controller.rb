class Instruction::ArchiveAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_archive

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

  def authorize_authorization_request_archive
    authorize [:instruction, @authorization_request], :archive?
  end
end
