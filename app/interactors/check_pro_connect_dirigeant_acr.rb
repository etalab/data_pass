class CheckProConnectDirigeantACR < ApplicationInteractor
  def call
    return if acr == OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE

    revoke_dirigeant_certification
    context.fail!(error: :acr_not_dirigeant)
  end

  private

  def acr
    context.pro_connect_omniauth_payload.dig('extra', 'acr')
  end

  def revoke_dirigeant_certification
    return if context.user.blank? || context.organization.blank?

    context.user.organizations_users.find_by(organization: context.organization)&.update!(dirigeant_verified_at: nil)
  end
end
