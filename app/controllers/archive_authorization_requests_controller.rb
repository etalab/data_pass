class ArchiveAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :authorize_authorization_request_archive

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
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id]).decorate
  end

  def authorize_authorization_request_archive
    authorize @authorization_request, :archive?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
