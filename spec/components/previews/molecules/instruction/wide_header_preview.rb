# @label Bandeau large de l’espace instruction
#
# Bandeau bleu clair placé en haut des pages de l’espace instruction : fil d’Ariane facultatif, logo
# ou pictogramme, titre de niveau 1, zone de sous-titre et zone d’actions à droite.
#
# **Où** : espace instruction, directement dans `instruction/authorization_definitions/index`, et
# via les en-têtes qui l’enveloppent — `AuthorizationDefinition::ShowHeaderComponent`,
# `AuthorizationDefinition::FormsHeaderComponent`, `AuthorizationDefinition::TitledHeaderComponent`
# et `Form::ShowHeaderComponent`.
#
# Le logo ne s’affiche que si le fichier est réellement attaché (`logo_asset&.attached?`), et la
# colonne de droite disparaît quand aucun contenu n’est passé à `with_right_content`.
class Molecules::Instruction::WideHeaderPreview < ApplicationPreview
  # @label 1. Titre seul
  #
  # Le bandeau réduit à son minimum : un titre de niveau 1, sans fil d’Ariane, sans logo et sans
  # colonne de droite — celle-ci disparaît faute de contenu passé à `with_right_content`.
  #
  # **Où** : espace instruction, en haut des pages — directement dans
  # `instruction/authorization_definitions/index`, sinon via les en-têtes qui l’enveloppent.
  def minimal
    render Molecules::Instruction::WideHeader.new(title: 'Fournisseurs de données')
  end

  # @label 2. Avec une action à droite
  #
  # Le même bandeau avec un bouton dans `with_right_content` : la colonne de droite apparaît et le
  # titre se resserre. C’est la forme utilisée par les pages qui proposent une action principale.
  #
  # **Où** : espace instruction, en haut des pages — directement dans
  # `instruction/authorization_definitions/index`, sinon via les en-têtes qui l’enveloppent.
  def with_right_content
    render Molecules::Instruction::WideHeader.new(title: 'Fournisseurs de données') do |component|
      component.with_right_content do
        tag.button('Ajouter des choses aux trucs', class: 'fr-btn fr-btn--sm fr-icon-add-line fr-btn--icon-left')
      end
    end
  end

  # @label 3. Avec fil d’Ariane
  #
  # Ajout du fil d’Ariane au-dessus du titre : le dernier élément, sans `href`, est rendu comme la
  # page courante et non comme un lien.
  #
  # **Où** : espace instruction, en haut des pages — directement dans
  # `instruction/authorization_definitions/index`, sinon via les en-têtes qui l’enveloppent.
  def with_breadcrumbs
    render Molecules::Instruction::WideHeader.new(
      title: 'API Particulier',
      breadcrumbs: [
        { label: 'Formulaires', href: '#' },
        { label: 'API Particulier' }
      ]
    )
  end

  # @label 4. Toutes les options réunies
  #
  # Fil d’Ariane, logo, sous-titre et action réunis : c’est ce que produisent les en-têtes qui
  # enveloppent ce composant. Le logo n’est rendu que parce que le fichier est réellement attaché
  # (`logo_asset&.attached?`).
  #
  # **Où** : espace instruction, en haut des pages — directement dans
  # `instruction/authorization_definitions/index`, sinon via les en-têtes qui l’enveloppent.
  def with_all_options
    authorization_definition = AuthorizationDefinition.find('api_entreprise')

    render Molecules::Instruction::WideHeader.new(
      title: 'API Particulier',
      logo_asset: authorization_definition.provider.logo,
      breadcrumbs: [
        { label: 'Formulaires', href: '#' },
        { label: 'API Particulier' }
      ]
    ) do |component|
      component.with_subtitle_content do
        tag.p('Sous-titre du fournisseur de données', class: 'fr-mb-0')
      end

      component.with_right_content do
        tag.button('Ajouter des choses aux trucs', class: 'fr-btn fr-btn--sm fr-icon-add-line fr-btn--icon-left')
      end
    end
  end
end
