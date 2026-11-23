class Molecules::WalletRegistry::IntendedUseHeaderComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(use:, title_id:, body_id:)
    @use = use
    @title_id = title_id
    @body_id = body_id
  end

  private

  attr_reader :use, :title_id, :body_id

  def summarized_attestations
    use.attestations.filter_map do |attestation|
      claims = wallet_selected_claims(attestation)
      [attestation.name, claims.map { |claim| claim.label.downcase }.join(', ')] if claims.any?
    end
  end
end
