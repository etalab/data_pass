class TransitionAuthorizationRequestToRevokedIfNeeded < ApplicationInteractor
  def call
    return unless no_active_authorization?
    return unless context.authorization_request.can_revoke?

    context.authorization_request.revoke!
  end

  private

  def no_active_authorization?
    context.authorization_request.authorizations.reload.none?(&:active?)
  end
end
