class MarkAuthorizationsAsRevoked < ApplicationInteractor
  def call
    toggle_revoked_boolean_on_authorizations_to(true)
  end

  def rollback
    toggle_revoked_boolean_on_authorizations_to(false)
  end

  private

  def toggle_revoked_boolean_on_authorizations_to(revoked)
    authorizations.find_each do |authorization|
      authorization.update(revoked:)
    end
  end

  def authorizations
    Authorization.joins(:request).where(authorization_requests: { id: context.authorization_request.id })
  end
end
