class CheckProConnectDirigeantSiret < ApplicationInteractor
  def call
    return context.fail!(error: :organization_without_siren) if organization_siret.blank?
    return if returned_siret.to_s.match?(/\A#{organization_siret.first(9)}\d{5}\z/)

    context.fail!(error: :siret_outside_siren)
  end

  private

  def organization_siret
    context.organization&.siret
  end

  def returned_siret
    context.pro_connect_omniauth_payload.dig('extra', 'raw_info', 'siret')
  end
end
