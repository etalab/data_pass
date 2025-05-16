class API::V1::AuthorizationRequestsController < API::V1Controller
  before_action :set_authorization_request, only: [:show]

  def index
    authorization_requests = AuthorizationRequest
      .includes(:authorizations, :organization, :events_without_bulk_update)
      .where(type: current_user_authorization_request_types)
      .merge(state_filter)
      .offset(params[:offset])
      .limit(maxed_limit(params[:limit]))

    render json: authorization_requests,
      each_serializer: API::V1::AuthorizationRequestSerializer,
      include: %w[habilitations organisation events],
      status: :ok
  end

  def show
    render json: @authorization_request,
      serializer: API::V1::AuthorizationRequestSerializer,
      include: %w[habilitations organisation events],
      status: :ok
  end

  private

  def state_filter
    return AuthorizationRequest.all if params[:state].blank?

    AuthorizationRequest.where(state: Array(params[:state]))
  end
end
