class CheckProConnectDirigeantACR < ApplicationInteractor
  def call
    return if acr == OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE

    context.fail!(error: :acr_not_dirigeant)
  end

  private

  def acr
    context.pro_connect_omniauth_payload.dig('extra', 'acr')
  end
end
