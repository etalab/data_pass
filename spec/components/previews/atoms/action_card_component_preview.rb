# @label Carte d’action (configuration d’une API)
#
# Carte cliquable dans son ensemble (`fr-enlarge-link`) menant à un écran de configuration, avec un
# titre, une description et, en pied de carte, un compteur facultatif précédé d’une icône.
#
# **Où** : espace instruction, page de configuration d’une API
# (`instruction/authorization_definitions/show`), dans le bloc « Actions » — trois cartes côte à
# côte : étapes du formulaire, cas d’usage, emails automatiques.
class Atoms::ActionCardComponentPreview < ApplicationPreview
  # @label 1. Avec compteur et icône
  #
  # La carte complète : titre, description, et en pied de carte le compteur « 5 étapes » précédé de
  # son icône. Toute la carte est cliquable (`fr-enlarge-link`).
  #
  # **Où** : espace instruction, page de configuration d’une API
  # (`instruction/authorization_definitions/show`), dans le bloc « Actions ».
  def with_detail
    render Atoms::ActionCardComponent.new(
      title: 'Modifier les étapes du formulaire',
      description: 'Ajoutez, configurez, réorganisez ou supprimez les étapes présentées au demandeur.',
      link: '#',
      detail: '5 étapes',
      icon: 'fr-icon-draft-line'
    )
  end

  # @label 2. Sans compteur
  #
  # La même carte sans `detail` ni `icon` : le pied de carte disparaît entièrement, ce qui est le
  # rendu de la carte « Gérer les emails automatiques ».
  #
  # **Où** : espace instruction, page de configuration d’une API
  # (`instruction/authorization_definitions/show`), dans le bloc « Actions ».
  def without_detail
    render Atoms::ActionCardComponent.new(
      title: 'Gérer les emails automatiques',
      description: 'Consultez le contenu et les destinataires des emails automatiques.',
      link: '#'
    )
  end
end
