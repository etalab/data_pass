class API::V1::AuthorizationRequestsController < API::V1Controller
  before_action -> { doorkeeper_authorize! :read_authorizations }, only: %i[index show]
  before_action -> { doorkeeper_authorize! :write_authorizations }, only: %i[create update]
  before_action :set_authorization_request, only: %i[show update]

  def index
    authorization_requests = AuthorizationRequest
      .includes(:authorizations, :organization, :events_without_bulk_update, :applicant)
      .where(type: current_user_authorization_request_types)
      .merge(state_filter)
      .merge(siret_filter)
      .offset(params[:offset])
      .limit(maxed_limit(params[:limit]))

    render json: authorization_requests,
      each_serializer: API::V1::AuthorizationRequestSerializer,
      include: %w[habilitations organisation applicant events],
      status: :ok
  end

  def show
    render_authorization_request(@authorization_request)
  end

  def create
    result = create_authorization_request

    if result.success?
      render_authorization_request(result.authorization_request, status: :created)
    else
      render_interactor_errors(result)
    end
  end

  def update
    result = UpdateAuthorizationRequestFromAPI.call(
      authorization_request: @authorization_request,
      authorization_request_form: @authorization_request.form,
      authorization_request_params: data_params,
      user: current_user
    )

    if result.success?
      render_authorization_request(result.authorization_request.reload)
    else
      render_interactor_errors(result)
    end
  end

  private

  def set_authorization_request
    @authorization_request = AuthorizationRequest
      .includes(:authorizations, :organization, :events_without_bulk_update, :applicant)
      .where(type: current_user_authorization_request_types)
      .find(params[:authorization_request_id] || params[:id])
  end

  def state_filter
    return AuthorizationRequest.all if params[:state].blank?

    AuthorizationRequest.where(state: Array(params[:state]))
  end

  def siret_filter
    return AuthorizationRequest.all if params[:siret].blank?

    AuthorizationRequest.joins(:organization).where(organizations: { legal_entity_id: params[:siret] })
  end

  def demande_params
    @demande_params ||= params.fetch(:demande, ActionController::Parameters.new)
  end

  def applicant_params
    demande_params.expect(applicant: %i[email given_name family_name job_title phone_number])
  end

  def data_params
    demande_params.fetch(:data, ActionController::Parameters.new)
  end

  def create_authorization_request
    CreateAuthorizationRequestFromAPI.call(
      form_uid: demande_params[:form_uid],
      type: demande_params[:type],
      authorized_types: current_user_authorization_request_types,
      authorization_request_params: data_params,
      applicant_params: applicant_params.to_h.symbolize_keys,
      siret: demande_params.dig(:organization, :siret),
      user: current_user
    )
  end

  def render_authorization_request(authorization_request, status: :ok)
    render json: authorization_request,
      serializer: API::V1::AuthorizationRequestSerializer,
      include: %w[habilitations organisation applicant events],
      status:
  end

  def render_interactor_errors(result)
    api_error = APIErrorsFacade.from_interactor_result(result)

    render json: { errors: api_error.errors }, status: api_error.status
  end
end
