class AuthorizationDefinitionsController < AuthenticatedUserController
  include SubdomainsHelper

  def index
    @authorization_definitions = if registered_subdomain?
                                   registered_subdomain.authorization_definitions
                                 else
                                   AuthorizationDefinition.indexable
                                 end

    return unless @authorization_definitions.count == 1

    redirect_to new_authorization_request_path(id: @authorization_definitions.first.id)
  end
end
