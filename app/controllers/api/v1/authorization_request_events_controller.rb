class API::V1::AuthorizationRequestEventsController < API::V1Controller
  before_action :set_authorization_request
  before_action -> { doorkeeper_authorize! :read_authorization_requests }, only: :index

  def index
    render json: @authorization_request.events,
      each_serializer: API::V1::AuthorizationRequestEventSerializer,
      status: :ok
  end
end
