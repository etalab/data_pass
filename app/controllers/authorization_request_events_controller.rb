class AuthorizationRequestEventsController < AuthenticatedUserController
  include AuthorizationOrRequestContext

  def index
    authorize @authorization_request, :events?

    @events = @authorization_request.events.includes(%i[authorization_request user entity]).order(created_at: :desc)
  end
end
