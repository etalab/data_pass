# @label État vide du tableau de bord
#
# Pictogramme, message et action facultative affichés à la place d’une liste vide.
#
# **Où** : tableau de bord demandeur, construit par `AbstractDashboardFacade`
# (`empty_state_component` et `no_results_component`).
#
# **Quand** : deux cas distincts — l’onglet ne contient aucune demande, avec un lien vers le
# catalogue data.gouv.fr ; ou un filtre de recherche ne renvoie aucun résultat, avec une action de
# réinitialisation.
class Dashboard::BlankStateComponentPreview < ApplicationPreview
  # @label 1. Aucune demande (lien vers le catalogue)
  #
  # Onglet vide dès le départ : le message invite à demander un premier accès, avec un lien vers le
  # catalogue data.gouv.fr ouvert dans un nouvel onglet.
  #
  # **Où** : tableau de bord demandeur, via `empty_state_component` de `AbstractDashboardFacade`.
  def default
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/document/document-add.svg',
      message: 'Vous n’avez pas encore de demandes en cours'
    ) do |component|
      component.with_action do
        link_to 'Demander un accès à des données',
          'https://www.data.gouv.fr/fr/dataservices',
          title: 'Demander un accès à des données - Ouvrir dans une nouvelle fenêtre',
          class: 'fr-link fr-link--action-high-blue-france',
          target: '_blank',
          rel: 'noopener noreferrer'
      end
    end
  end

  # @label 2. Aucun résultat de recherche (réinitialiser les filtres)
  #
  # L’onglet contient des demandes, mais aucune ne passe les filtres : l’action proposée
  # réinitialise la recherche au lieu de renvoyer vers le catalogue.
  #
  # **Où** : tableau de bord demandeur, via `no_results_component` de `AbstractDashboardFacade`.
  def with_button_action
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/digital/information.svg',
      message: 'Nous n’avons pas trouvé de demande avec les filtres que vous avez sélectionnés'
    ) do |component|
      component.with_action do
        link_to 'Réinitialiser les filtres', '#', class: 'fr-btn fr-btn--secondary'
      end
    end
  end

  # @label 3. Sans action
  #
  # Variante pictogramme et message seuls, sans lien ni bouton.
  #
  # **Où** : tableau de bord demandeur — cette variante n’est utilisée par aucun appel réel
  # aujourd’hui, les deux états du tableau de bord fournissant tous les deux une action.
  def without_action
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/digital/information.svg',
      message: 'Aucune donnée disponible'
    )
  end

  # @label 4. Avec une classe CSS personnalisée sur l’image
  #
  # Montre le point d’extension `pictogram_class`, qui remplace la classe par défaut du pictogramme,
  # ainsi que le texte alternatif personnalisé.
  #
  # **Où** : tableau de bord demandeur — point d’extension non utilisé par les appels réels, qui
  # laissent la classe par défaut.
  def with_custom_image_class
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/document/document-add.svg',
      pictogram_alt: 'Illustration',
      pictogram_class: 'fr-responsive-img custom-class',
      message: 'Composant avec classe CSS personnalisée pour l’image'
    ) do |component|
      component.with_action do
        link_to 'Action personnalisée', '#', class: 'fr-btn'
      end
    end
  end
end
