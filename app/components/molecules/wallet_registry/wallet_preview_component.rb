class Molecules::WalletRegistry::WalletPreviewComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(authorization_request:, uses:, previewed_use: nil)
    @authorization_request = authorization_request
    @uses = uses
    @previewed_use = previewed_use || uses.first
  end

  private

  attr_reader :authorization_request, :uses, :previewed_use

  def service_name
    authorization_request.wallet_service_name.presence || t('authorization_request_forms.registre_wallet.wallet_service.preview.placeholder')
  end

  def selected_attestations(use)
    use.attestations.map { |attestation| [attestation, wallet_selected_claims(attestation)] }.reject { |_, claims| claims.empty? }
  end
end
