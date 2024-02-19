class ArchiveAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization_request

  def new; end

  def create
    organizer = ArchiveAuthorizationRequest.call(authorization_request: @authorization_request, user: current_user)

    if organizer.success?
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to dashboard_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])

    authorize @authorization_request, :archive?
  end
end
