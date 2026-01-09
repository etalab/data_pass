class FranceConnectedAuthorizationsController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :extract_authorization_or_request
  decorates_assigned :authorization_request, :authorization

  def index
    authorize @authorization_request, :france_connected_authorizations?

    @france_connected_authorizations = @authorization_request.france_connected_authorizations.decorate
  end

  private

  def extract_authorization_or_request
    if params[:authorization_id].present?
      @authorization = Authorization.friendly.find(params[:authorization_id])
      @authorization_request = @authorization.request
    else
      @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
    end
  end

  def layout_name
    return 'authorization_with_tabs' if @authorization.present?

    'authorization_request_with_tabs'
  end
end
