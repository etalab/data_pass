class Organisms::WalletRegistry::IntendedUseDataComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(use:, index:, focus_key: nil)
    @use = use
    @index = index
    @focus_key = focus_key
  end

  private

  attr_reader :use, :index

  def focus?(key)
    @focus_key.present? && @focus_key == key
  end

  def attestation_focus_key(attestation)
    "attestation_#{attestation.rulebook_id}"
  end

  def open_attestation
    @open_attestation ||= use.attestations.find { |attestation| focus?(attestation_focus_key(attestation)) } ||
                          use.attestations.find { |attestation| use.claim_error_for(attestation) } ||
                          use.attestations.first
  end

  def attestations_error
    @attestations_error ||= use.errors.where(:attestations, :blank).first
  end

  def add_button_id
    wallet_intended_use_dom_id(index, 'attestations')
  end

  def add_button_attributes
    {
      id: add_button_id,
      aria: { controls: "wallet-catalog-#{use.id}", describedby: ("#{add_button_id}-messages" if attestations_error) },
      data: { fr_opened: 'false' },
      autofocus: focus?('add_attestation')
    }
  end
end
