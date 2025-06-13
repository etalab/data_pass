class AuthorizationsController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :set_authorization, only: :show
  decorates_assigned :authorization

  def show
    authorize @authorization, :show?
    @authorization_as_request_validated = @authorization.request_as_validated.decorate
  end

  private

  def set_authorization
    @authorization = Authorization.friendly.find(params[:id])
  end

  def layout_name
    'authorization_request'
  end
end
