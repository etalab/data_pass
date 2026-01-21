class API::V1::AuthorizationsController < API::V1Controller
  before_action :set_authorization, only: :show
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: :index

  def show
    render json: @authorization,
      serializer: API::V1::AuthorizationDetailedSerializer,
      include: %w[organisation],
      status: :ok
  end

  def index
    @authorizations = Authorization
      .includes(:organization)
      .where(authorization_request_class: current_user_authorization_request_types)
      .merge(state_filter)
      .merge(siret_filter)
      .offset(params[:offset])
      .limit(maxed_limit(params[:limit]))

    render json: @authorizations,
      each_serializer: API::V1::AuthorizationDetailedSerializer,
      include: %w[organisation],
      status: :ok
  end

  private

  def state_filter
    return Authorization.all if params[:state].blank?

    Authorization.where(state: Array(params[:state]))
  end

  def siret_filter
    return Authorization.all if params[:siret].blank?

    Authorization.joins(request: :organization).where(organizations: { legal_entity_id: params[:siret] })
  end
end
