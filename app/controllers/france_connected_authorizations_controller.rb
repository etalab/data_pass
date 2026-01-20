class FranceConnectedAuthorizationsController < AuthenticatedUserController
  include AuthorizationOrRequestContext

  def index
    authorize @authorization_request, :france_connected_authorizations?

    @france_connected_authorizations = @authorization_request.france_connected_authorizations.decorate
  end
end
