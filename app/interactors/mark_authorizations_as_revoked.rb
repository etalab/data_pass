class MarkAuthorizationsAsRevoked < ApplicationInteractor
  def call
    authorizations.each(&:revoke!)
  end

  private

  def authorizations
    Authorization.joins(:request).where(authorization_requests: { id: context.authorization_request.id })
  end
end
