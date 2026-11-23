# @label Confirmation avant suppression (étape « Les utilisations prévues » du registre wallet)
#
# Modale DSFR (rôle `alertdialog`) qui demande confirmation avant de supprimer une utilisation prévue ou de retirer
# une attestation. Le bouton principal envoie la commande de l’étape, « Annuler » referme la modale. La preview
# affiche le bouton qui l’ouvre.
#
# **Où** : registre wallet, étape 3, sous chaque utilisation et sous chaque attestation.
class Molecules::WalletRegistry::ConfirmationModalComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Supprimer une utilisation qui a des données cochées
  def delete_use
    use = majority_use
    render_with_trigger Molecules::WalletRegistry::ConfirmationModalComponent.delete_use(authorization_request: use.authorization_request, use:), "wallet-delete-use-#{use.id}"
  end

  # @label 2. Supprimer une utilisation sans nom ni donnée
  def delete_blank_use
    use = blank_use
    render_with_trigger Molecules::WalletRegistry::ConfirmationModalComponent.delete_use(authorization_request: use.authorization_request, use:), "wallet-delete-use-#{use.id}"
  end

  # @label 3. Retirer une attestation et ses données cochées
  def remove_attestation
    use = account_use
    attestation = use.attestations.first
    component = Molecules::WalletRegistry::ConfirmationModalComponent.remove_attestation(authorization_request: use.authorization_request, use:, attestation:, claim_count: attestation.claim_count)

    render_with_trigger component, "wallet-remove-attestation-#{use.id}-#{attestation.rulebook_id}"
  end

  private

  def render_with_trigger(component, modal_id)
    render_with_template(template: 'molecules/wallet_registry/confirmation_modal_component_preview/with_trigger', locals: { component:, modal_id: })
  end
end
