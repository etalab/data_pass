class SaveAuthorizationRequestIdentity < ApplicationInteractor
  def call
    context.authorization_request.with_lock do
      context.authorization_request.copy_identity_from_sources
      context.authorization_request.save!(validate: false)
    end
  end
end
