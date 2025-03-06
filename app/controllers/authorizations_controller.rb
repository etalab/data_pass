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
    @authorization = if params[:authorization_request_id]
                       AuthorizationRequest.find(params[:authorization_request_id]).authorizations.friendly.find(params[:id])
                     else
                       Authorization.friendly.find(params[:id])
                     end
  end

  def layout_name
    'authorization_request'
  end
end
