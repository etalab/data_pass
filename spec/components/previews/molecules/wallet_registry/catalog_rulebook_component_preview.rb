# @label Attestation du catalogue (étape « Les utilisations prévues » du registre wallet)
#
# Une attestation dans les résultats du catalogue : nom, badge, lien vers la documentation de la Commission, nombre
# de données et ligne technique, puis le bouton d’ajout. Dans la fenêtre, le bouton envoie le formulaire de l’étape
# (rien de ce qui est saisi n’est perdu) ; en page entière, sans JavaScript, il envoie sa propre commande.
#
# **Où** : registre wallet, étape 3, fenêtre du catalogue et sa page entière.
class Molecules::WalletRegistry::CatalogRulebookComponentPreview < ApplicationPreview
  include Molecules::WalletRegistry::IntendedUsesPreviewData

  # @label 1. À ajouter, dans la fenêtre
  def addable_embedded
    render_rulebook('pid', embedded: true)
  end

  # @label 2. À ajouter, en page entière (sans JavaScript)
  def addable_full_page
    render_rulebook('pid', embedded: false)
  end

  # @label 3. Déjà ajoutée à l’utilisation, attestation provisoire
  def already_added
    render_rulebook('mdl', embedded: true)
  end

  private

  def render_rulebook(identifier, embedded:)
    use = majority_use

    render_with_template(template: 'molecules/wallet_registry/catalog_rulebook_component_preview/in_list',
      locals: { component: Molecules::WalletRegistry::CatalogRulebookComponent.new(authorization_request: use.authorization_request, use:, rulebook: rulebook(identifier), embedded:) })
  end
end
