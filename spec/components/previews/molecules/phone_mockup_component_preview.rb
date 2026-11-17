# @label Téléphone fictif
#
# Aperçu d’un écran de portefeuille européen dans un téléphone. Le dessin est masqué aux lecteurs
# d’écran (`aria-hidden`) et remplacé par une légende `fr-sr-only` reliée à la `figure`.
#
# **Où** : accueil public, encart « Portefeuille européen ».
class Molecules::PhoneMockupComponentPreview < ApplicationPreview
  # @label 1. Demande de partage de données
  #
  # Organisation, données demandées, finalité, mention du registre et boutons « Refuser » et
  # « Partager », tels qu’ils s’affichent dans l’encart de l’accueil, via le helper
  # `european_wallet_phone_mockup` qui porte les textes partagés (`shared.european_wallet_phone`).
  def default
    render european_wallet_phone_mockup(caption_id: 'apercu-telephone-legende')
  end

  # @label 2. Sans mention ni boutons
  #
  # Variante sans ligne de statut ni boutons, pour un écran d’information (attestation reçue par
  # exemple).
  def without_status_nor_actions
    render Molecules::PhoneMockupComponent.new(
      caption: { id: 'apercu-attestation-legende', text: 'Exemple fictif : une attestation dans le portefeuille.' },
      header: { avatar: 'A', title: 'Attestation de diplôme', subtitle: 'Délivrée par une université' },
      rows: [
        { label: 'Diplôme', value: 'Licence de géographie' },
        { label: 'Année', value: '2024' }
      ]
    )
  end
end
