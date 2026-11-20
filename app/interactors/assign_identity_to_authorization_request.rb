class AssignIdentityToAuthorizationRequest < ApplicationInteractor
  def call
    return unless context.authorization_request.respond_to?(:copy_identity_from_sources)

    context.authorization_request.copy_identity_from_sources
  end
end
