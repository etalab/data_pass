class Molecules::WalletRegistry::CatalogRulebookComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(authorization_request:, use:, rulebook:, embedded:)
    @authorization_request = authorization_request
    @use = use
    @rulebook = rulebook
    @embedded = embedded
  end

  private

  attr_reader :authorization_request, :use, :rulebook, :embedded

  def already_added?
    use.attestation_for(rulebook.id).present?
  end

  def add_label
    safe_join([wallet_intended_uses_t('catalog.add'), tag.span(" #{rulebook.name}", class: 'fr-sr-only')])
  end

  def command
    "add_attestation:#{use.id}:#{rulebook.id}"
  end
end
