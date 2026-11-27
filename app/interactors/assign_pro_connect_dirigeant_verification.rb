class AssignProConnectDirigeantVerification < ApplicationInteractor
  def call
    context.verification = {
      siren: context.organization.siret.first(9),
      siret: payload.dig('extra', 'raw_info', 'siret'),
      sub: payload['uid'],
      acr: payload.dig('extra', 'acr'),
      amr: payload.dig('extra', 'amr'),
      verified_at: Time.zone.now
    }
  end

  private

  def payload
    context.pro_connect_omniauth_payload
  end
end
