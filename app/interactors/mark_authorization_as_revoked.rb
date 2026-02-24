class MarkAuthorizationAsRevoked < ApplicationInteractor
  def call
    context.authorization.revoke!
  end

  def rollback
    context.authorization.rollback_revoke!
  end
end
