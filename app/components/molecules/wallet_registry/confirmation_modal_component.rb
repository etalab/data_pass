class Molecules::WalletRegistry::ConfirmationModalComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def self.delete_use(authorization_request:, use:)
    new(
      authorization_request:,
      modal_id: "wallet-delete-use-#{use.id}",
      command: "remove_use:#{use.id}",
      wording_key: 'delete_use_modal',
      interpolations: { title: { name: use.display_name }, detail: { count: use.claim_count } }
    )
  end

  def self.remove_attestation(authorization_request:, use:, attestation:, claim_count:)
    new(
      authorization_request:,
      modal_id: "wallet-remove-attestation-#{use.id}-#{attestation.rulebook_id}",
      command: "remove_attestation:#{use.id}:#{attestation.rulebook_id}",
      wording_key: 'remove_attestation_modal',
      interpolations: { title: { name: attestation.name }, detail: { count: claim_count, use_name: use.display_name } }
    )
  end

  def initialize(authorization_request:, modal_id:, command:, wording_key:, interpolations: {})
    @authorization_request = authorization_request
    @modal_id = modal_id
    @command = command
    @wording_key = wording_key
    @interpolations = interpolations
  end

  private

  attr_reader :authorization_request, :modal_id, :command

  def wording(key)
    wallet_intended_uses_t("#{@wording_key}.#{key}", **@interpolations.fetch(key, {}))
  end
end
