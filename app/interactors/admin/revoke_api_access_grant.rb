class Admin::RevokeAPIAccessGrant < ApplicationInteractor
  def call
    revoked = context.grant.revoke!(by_id: context.admin.id, by_email: context.admin.email, reason: context.reason)

    return if revoked

    context.fail!(error: :model_error, model: context.grant)
  end
end
