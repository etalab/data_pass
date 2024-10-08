class AuthorizationsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  def show
    @authorization = AuthorizationRequest.find(params[:authorization_request_id]).authorizations.friendly.find(params[:id])

    authorize @authorization, :show?

    @authorization_request = @authorization.request_as_validated.decorate

    render 'authorization_request_forms/summary'
  end

  private

  def layout_name
    'authorization_request'
  end
end
