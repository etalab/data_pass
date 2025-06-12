class AuthorizationsController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :set_authorization, only: :show
  decorates_assigned :authorization

  def show
    authorize @authorization, :show?

    # @authorization_request = @authorization.request_as_validated.decorate
    @form_builder = AuthorizationRequestFormBuilder.new(
      'authorization_request',
      @authorization.request_as_validated,
      view_context,
      {}
    )
  end

  private

  def set_authorization
    @authorization = Authorization.friendly.find(params[:id])
  end

  def layout_name
    'authorization_request'
  end
end
