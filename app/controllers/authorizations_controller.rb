class AuthorizationsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :set_authorization, only: :show

  def show
    authorize @authorization, :show?

    @authorization_request = @authorization.request_as_validated.decorate

    render 'authorization_request_forms/summary'
  end

  private

  def set_authorization
    @authorization = Authorization.find(params[:id])
  end

  def layout_name
    'authorization_request'
  end
end
