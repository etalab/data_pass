class API::V1::AuthorizationRequestFormsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: %i[index]
  before_action :set_authorization_definition, only: %i[index]

  def index
    authorization_request_forms = @authorization_definition.available_forms

    render json: authorization_request_forms,
      each_serializer: API::V1::AuthorizationRequestFormSerializer,
      status: :ok
  end
end
