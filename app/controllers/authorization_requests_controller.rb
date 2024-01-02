class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  def index
    @authorization_definitions = AuthorizationDefinition.indexable
  end

  def new
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
  end

  private

  def id_sanitized
    params[:id].underscore
  end
end
