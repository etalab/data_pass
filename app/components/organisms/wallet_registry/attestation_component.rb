class Organisms::WalletRegistry::AttestationComponent < ApplicationComponent
  include Molecules::WalletRegistry::IntendedUsesHelpers

  def initialize(use:, index:, attestation:, open:, focused: false)
    @use = use
    @index = index
    @attestation = attestation
    @open = open
    @focused = focused
  end

  private

  attr_reader :use, :index, :attestation, :open, :focused

  delegate :authorization_request, to: :use

  def attestation_index
    use.attestations.index(attestation)
  end

  def button_id
    wallet_intended_use_dom_id(index, "attestation_#{attestation.rulebook_id}")
  end

  def collapse_id
    "#{button_id}-collapse"
  end

  def message_id
    "#{button_id}-messages"
  end

  def claim_ids
    @claim_ids ||= attestation.selected_claim_ids
  end

  def claim_error
    @claim_error ||= use.claim_error_for(attestation)
  end

  def claims_param
    "#{wallet_attestation_param(index, attestation_index, 'selected_claim_ids')}[]"
  end

  def checked_count(group)
    group[:claims].count { |claim| claim_ids.include?(claim.id) }
  end

  def checkbox_id(claim)
    wallet_intended_use_dom_id(index, "claim_#{attestation.rulebook_id}_#{claim.identifier}")
  end

  def claim_mentions(claim)
    mentions = []
    mentions << wallet_intended_uses_t("attestation.presence.#{claim.requirement}") if claim.may_be_missing?
    mentions << wallet_intended_uses_t('attestation.single_format', format_name: claim_format_label(claim)) if attestation.formats.size > claim.format_count
    mentions
  end

  def claim_format_label(claim)
    format_ids = claim.paths.map(&:rulebook_format_id)
    attestation.formats.find { |format| format_ids.include?(format.id) }&.label
  end
end
