class RefreshAuthorizationRequestIdentitySources < ApplicationInteractor
  def call
    refreshed = context.authorization_request.refresh_identity_sources
    context.authorization_request.organization.reload

    return if refreshed

    mark_identity_unavailable
    context.fail!(error: :identity_sources_unavailable)
  end

  private

  def mark_identity_unavailable
    context.authorization_request.with_lock do
      context.authorization_request.mark_identity_unavailable
      context.authorization_request.save!(validate: false)
    end
  end
end
