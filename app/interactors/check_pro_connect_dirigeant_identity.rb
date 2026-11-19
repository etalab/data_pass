class CheckProConnectDirigeantIdentity < ApplicationInteractor
  def call
    return if same_pro_connect_account?

    context.fail!(error: :identity_mismatch)
  end

  private

  def same_pro_connect_account?
    context.user.external_id.present? && context.user.external_id == context.pro_connect_omniauth_payload['uid']
  end
end
