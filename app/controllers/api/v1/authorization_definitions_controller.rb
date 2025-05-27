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

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.all.find do |definition|
      definition.id == params[:id] &&
        current_user_authorization_request_types.include?(definition.authorization_request_class.to_s)
    end

    head :not_found unless @authorization_definition
  end
end
