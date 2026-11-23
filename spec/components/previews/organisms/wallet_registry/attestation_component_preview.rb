# @label Attestation demandée (étape « Les utilisations prévues » du registre wallet)
#
# Accordéon d’une attestation du catalogue dans une utilisation prévue : nombre de données cochées, badges, détails
# techniques repliables, données par groupe avec leurs mentions (« peut être absente », « seulement en SD-JWT »…),
# puis « Retirer l’attestation », qui ouvre une confirmation.
#
# **Où** : registre wallet, étape 3, dans la section « Données demandées » de chaque utilisation.
class Organisms::WalletRegistry::AttestationComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Ouverte, une donnée cochée, attestation provisoire (permis de conduire)
  def open_provisional
    render_attestation(majority_use, open: true)
  end

  # @label 2. Fermée
  def closed
    render_attestation(majority_use, open: false)
  end

  # @label 3. Plusieurs données cochées, mentions par format (PID)
  def pid_with_mentions
    render_attestation(account_use, open: true)
  end

  # @label 4. Aucune donnée cochée
  def no_claim
    render_attestation(account_use(claims: []), open: true)
  end

  # @label 5. Erreur « au moins une donnée » après « Suivant »
  def no_claim_error
    use = account_use(claims: [])
    use.validate

    render_attestation(use, open: true)
  end

  private

  def render_attestation(use, open:)
    render Organisms::WalletRegistry::AttestationComponent.new(use:, index: 0, attestation: use.attestations.first, open:)
  end
end
