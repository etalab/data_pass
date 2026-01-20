class AuthorizationsController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :set_authorization_request, only: :index
  before_action :set_authorization, only: :show
  decorates_assigned :authorization, :authorizations, :authorization_request

  def index
    authorize @authorization_request, :summary?

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

  def set_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def set_authorization
    @authorization = Authorization.friendly.find(params[:id])
  end

  def layout_name
    return 'authorization_request_with_tabs' if action_name == 'index'

    'authorization_with_tabs'
  end
end
