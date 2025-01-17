class API::V1::AuthorizationRequestsController < API::V1Controller
  def index
    authorization_requests = AuthorizationRequest
      .where(type: valid_authorization_request_types)
      .offset(params[:offset])
      .limit(params.fetch(:limit, 10))

    if authorization_requests.any?
      render json: authorization_requests,
        each_serializer: API::V1::AuthorizationRequestSerializer,
        status: :ok
    else
      render_error(404, title: 'Non trouvé', detail: 'Aucune demande n\'a été trouvé')
    end
  end

  def show
    authorization_request = AuthorizationRequest
      .where(type: valid_authorization_request_types)
      .find(params[:id])

    render json: authorization_request,
      serializer: API::V1::AuthorizationRequestSerializer,
      status: :ok
  rescue ActiveRecord::RecordNotFound
    render_error(404, title: 'Non trouvé', detail: 'Aucune demande n\'a été trouvé')
  end

  private

  def valid_authorization_request_types
    current_user.developer_roles.map do |role|
      "AuthorizationRequest::#{role.split(':')[0].classify}"
    end
  end
end
