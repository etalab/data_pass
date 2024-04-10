class CreateRevocationOfAuthorizationModel < ApplicationInteractor
  def call
    context.revocation_of_authorization = authorization_request.revocations.build(
      revocation_of_authorization_params
    )

    return if context.revocation_of_authorization.save

    context.fail!
  end

  private

  def authorization_request
    context.authorization_request
  end

  def revocation_of_authorization_params
    context.revocation_of_authorization_params
  end
end
