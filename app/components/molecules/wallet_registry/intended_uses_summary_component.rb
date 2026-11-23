class Molecules::WalletRegistry::IntendedUsesSummaryComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(authorization_request:, uses:)
    @authorization_request = authorization_request
    @uses = uses
  end

  private

  attr_reader :authorization_request, :uses

  def use_title(use)
    use.name.presence || wallet_intended_uses_t('summary.unnamed')
  end

  def purpose(use)
    use.purpose.presence || wallet_intended_uses_t('summary.not_filled')
  end

  def privacy_policy(use)
    use.own_privacy_policy_url || wallet_intended_uses_t('summary.privacy_policy_inherited')
  end

  def selected_attestations(use)
    use.attestations.map { |attestation| [attestation, wallet_selected_claims(attestation)] }.reject { |_, claims| claims.empty? }
  end
end
