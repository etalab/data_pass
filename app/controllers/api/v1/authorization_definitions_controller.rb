class API::V1::AuthorizationDefinitionsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: %i[index show]
  before_action :set_authorization_definition, only: %i[show]

  def index
    authorization_definitions = AuthorizationDefinition.where(authorization_request_class: current_user_authorization_request_types)

    render json: authorization_definitions,
      each_serializer: API::V1::AuthorizationDefinitionSerializer,
      status: :ok
  end

  def show
    render json: @authorization_definition,
      serializer: API::V1::AuthorizationDefinitionSerializer,
      status: :ok
  end
end
