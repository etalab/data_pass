class API::V1::AuthorizationRequestEventsController < API::V1Controller
  before_action :set_authorization_request

  def index
    render json: @authorization_request.events,
      each_serializer: API::V1::AuthorizationRequestEventSerializer,
      status: :ok
  end

  private

  def set_authorization_request
    @authorization_request = AuthorizationRequest
      .where(type: valid_authorization_request_types)
      .find(params[:authorization_request_id])
  rescue ActiveRecord::RecordNotFound
    render_error(404, title: 'Non trouvé', detail: 'Aucune demande n\'a été trouvée')
  end

  def valid_authorization_request_types
    current_user.developer_roles.map do |role|
      "AuthorizationRequest::#{role.split(':')[0].classify}"
    end
  end
end
