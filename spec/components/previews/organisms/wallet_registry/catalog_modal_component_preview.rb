# @label Fenêtre du catalogue des attestations (étape « Les utilisations prévues » du registre wallet)
#
# Modale DSFR du catalogue de la Commission : recherche sans accents, résultats chargés dans un turbo-frame, et
# encart « Mon attestation n’est pas dans la liste ». Sans JavaScript, le bouton « Ouvrir le catalogue » mène à la
# page entière. Dans Lookbook, les résultats ne se chargent pas : le turbo-frame vise l’adresse d’une demande
# construite pour la preview.
#
# **Où** : registre wallet, étape 3, ouverte par « Ajouter une attestation ».
class Organisms::WalletRegistry::CatalogModalComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. Pour une utilisation nommée
  def named_use
    render_catalog(majority_use)
  end

  # @label 2. Pour une utilisation pas encore nommée
  def unnamed_use
    render_catalog(blank_use)
  end

  private

  def render_catalog(use)
    render_with_template(template: 'organisms/wallet_registry/catalog_modal_component_preview/with_trigger',
      locals: { component: Organisms::WalletRegistry::CatalogModalComponent.new(authorization_request: use.authorization_request, use:), modal_id: "wallet-catalog-#{use.id}" })
  end
end
