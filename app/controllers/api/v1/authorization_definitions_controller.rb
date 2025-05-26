class API::V1::AuthorizationDefinitionsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: %i[index]

  def index
    authorization_definitions = AuthorizationDefinition.all.select do |definition|
      current_user_authorization_request_types.include?(definition.authorization_request_class.to_s)
    end

    render json: authorization_definitions,
      each_serializer: API::V1::AuthorizationDefinitionSerializer,
      status: :ok
  end
end
