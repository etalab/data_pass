# @label En-tête d’une utilisation (étape « Les utilisations prévues » du registre wallet)
#
# En-tête de la carte d’une utilisation prévue : son nom, ses totaux, le résumé des données cochées par attestation
# (visible quand la carte est repliée), et les boutons « Supprimer » et « Replier ».
#
# **Où** : registre wallet, étape 3, en haut de chaque utilisation.
class Molecules::WalletRegistry::IntendedUseHeaderComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Sans nom ni attestation
  def blank
    render_header(blank_use)
  end

  # @label 2. Une attestation sans donnée cochée
  def attestation_without_claim
    render_header(account_use(claims: []))
  end

  # @label 3. Deux attestations cochées
  def two_attestations
    use = account_use
    add_attestation(use, 'mdl', claims: %w[age_over_18], id: 3)

    render_header(use)
  end

  private

  def render_header(use)
    render Molecules::WalletRegistry::IntendedUseHeaderComponent.new(use:, title_id: 'usage-title', body_id: 'usage-body')
  end
end
