class VerifyDirigeantThroughProConnect < ApplicationOrganizer
  organize CheckProConnectDirigeantAcr,
    CheckProConnectDirigeantIdentity,
    CheckProConnectDirigeantSiret

  after do
    context.verification = {
      siren: context.organization.siret.first(9),
      siret: context.pro_connect_omniauth_payload.dig('extra', 'raw_info', 'siret'),
      sub: context.pro_connect_omniauth_payload['uid'],
      acr: context.pro_connect_omniauth_payload.dig('extra', 'acr'),
      amr: context.pro_connect_omniauth_payload.dig('extra', 'amr'),
      verified_at: Time.zone.now
    }
  end
end
