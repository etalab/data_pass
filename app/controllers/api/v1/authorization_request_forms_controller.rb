class API::V1::AuthorizationRequestFormsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: %i[index]
  before_action :set_authorization_definition, only: %i[index]

  def index
    authorization_request_forms = @authorization_definition.available_forms

    render json: authorization_request_forms,
      each_serializer: API::V1::AuthorizationRequestFormSerializer,
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
