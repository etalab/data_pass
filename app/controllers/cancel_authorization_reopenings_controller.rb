class CancelAuthorizationReopeningsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  before_action :extract_authorization_request
  before_action :authorize_authorization_request_reopening_cancellation

  def new
    @authorization_request_reopening_cancellation = @authorization_request.reopening_cancellations.build
  end

  def create
    organizer = CancelAuthorizationReopening.call(authorization_request_reopening_cancellation_params: {}, authorization_request: @authorization_request, user: current_user)

    @authorization_request_reopening_cancellation = organizer.authorization_request_reopening_cancellation

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'cancel_authorization_reopenings.create')

      redirect_to dashboard_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def authorize_authorization_request_reopening_cancellation
    authorize @authorization_request, :cancel_reopening?
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end
end
