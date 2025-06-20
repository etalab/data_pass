class CancelNextAuthorizationRequestStageController < AuthenticatedUserController
  before_action :extract_authorization_request

  def new
    authorize @authorization_request, :cancel_next_stage?
  end

  def create
    authorize @authorization_request, :cancel_next_stage?

    organizer = CancelNextAuthorizationRequestStage.call(authorization_request: @authorization_request, user: current_user)
    @authorization_request = organizer.authorization_request

    success_message(title: t('.success'))
    redirect_to authorization_request_path(@authorization_request)
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end
end
