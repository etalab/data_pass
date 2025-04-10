class API::V1::AuthorizationsController < API::V1Controller
  before_action :set_authorization_request

  def index
    render json: @authorization_request.authorizations,
      each_serializer: API::V1::AuthorizationSerializer,
      status: :ok
  end
end
