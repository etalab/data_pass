class WalletRegistry::IntendedUseAttestation < ApplicationRecord
  belongs_to :intended_use, class_name: 'WalletRegistry::IntendedUse', inverse_of: :requested_attestations
  belongs_to :rulebook, class_name: 'WalletRegistry::Rulebook'
  has_many :requested_claims, class_name: 'WalletRegistry::IntendedUseClaim', inverse_of: :intended_use_attestation, dependent: :destroy, autosave: true

  delegate :name, :groups, :formats, :format_labels, :category, :version_label, :documentation_url, :provisional_note, to: :rulebook

  def selected_claim_ids
    requested_claims.reject(&:marked_for_destruction?).map(&:rulebook_claim_id)
  end

  def selected_claim_ids=(ids)
    wanted = rulebook_claim_ids_among(ids)

    requested_claims.each { |claim| claim.mark_for_destruction unless wanted.include?(claim.rulebook_claim_id) }
    (wanted - selected_claim_ids).each { |rulebook_claim_id| requested_claims.build(rulebook_claim_id:) }
  end

  def selected_claims
    ids = selected_claim_ids
    rulebook.claims.select { |claim| ids.include?(claim.id) }
  end

  def claim_count
    selected_claim_ids.size
  end

  def credentials
    claims = selected_claims
    formats.map { |format| format.credential_for(claims) }
  end

  private

  def rulebook_claim_ids_among(ids)
    WalletRegistry::RulebookClaim.where(rulebook_id:, id: Array(ids).compact_blank).ids
  end
end
