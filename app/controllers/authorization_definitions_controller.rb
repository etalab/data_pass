class AuthorizationDefinitionsController < AuthenticatedUserController
  include SubdomainsHelper

  def index
    @authorization_definitions = policy_scope(AuthorizationDefinition)

    return unless @authorization_definitions.one?

    redirect_to new_authorization_request_path(definition_id: @authorization_definitions.first.id)
  end
end
