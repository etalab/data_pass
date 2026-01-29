class AuthorizationsController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :set_context, only: :index
  before_action :set_authorization, only: :show
  decorates_assigned :authorization, :authorizations, :authorization_request

  def index
    authorize authorization_or_request, :authorizations?

    @authorizations = @authorization_request
      .authorizations
      .includes(:approving_instructor)
      .order(created_at: :desc)
  end

  def show
    authorize @authorization, :show?
    @authorization_as_request_validated = @authorization.request_as_validated.decorate
  end

  private

  def set_context
    if params[:authorization_id].present?
      @authorization = Authorization.friendly.find(params[:authorization_id])
      @authorization_request = @authorization.request
    else
      @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
    end
  end

  def set_authorization
    @authorization = Authorization.friendly.find(params[:id])
  end

  def authorization_or_request
    @authorization || @authorization_request
  end

  def layout_name
    return 'authorization_with_tabs' if @authorization.present?

    'authorization_request_with_tabs'
  end
end
