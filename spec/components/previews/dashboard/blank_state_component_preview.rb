class Dashboard::BlankStateComponentPreview < ApplicationPreview
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

  def with_button_action
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/digital/information.svg',
      message: 'Nous n’avons pas trouvé de demande avec les filtres que vous avez sélectionné'
    ) do |component|
      component.with_action do
        link_to 'Réinitialiser les filtres', '#', class: 'fr-btn fr-btn--secondary'
      end
    end
  end

  def without_action
    render Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/digital/information.svg',
      message: 'Aucune donnée disponible'
    )
  end

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
