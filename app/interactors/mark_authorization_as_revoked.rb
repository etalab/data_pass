class MarkAuthorizationAsRevoked < ApplicationInteractor
  def call
    context.authorization.revoke!
  end
end
