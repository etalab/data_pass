# @label Bouton de copie dans le presse-papiers
#
# Bouton secondaire à icône presse-papiers qui copie un texte, accompagné d’une zone de statut
# invisible à l’écran qui annonce la copie aux lectrices et lecteurs d’écran.
#
# **Où** : espace instruction, dans l’en-tête des pages de consultation d’un formulaire
# (`instruction/forms/show`) et d’une définition d’habilitation
# (`instruction/authorization_definitions/show`), à droite du titre. Il est toujours rendu par
# `Atoms::FormButtonsComponent`, avec le libellé « Copier le lien de demande » et la classe
# supplémentaire `authorization-definition-action-btn` pour aligner sa largeur sur le bouton «
# Initier une demande pour autrui », affiché juste au-dessus quand un chemin d’initiation est
# fourni.
#
# Le retour de copie passe par le contrôleur Stimulus `clipboard` : le libellé du bouton change à la
# volée, d’où l’option `lock-width` qui fige sa largeur pour éviter que la mise en page ne sursaute.
class Atoms::CopyButtonComponentPreview < ApplicationPreview
  # @label 1. Bouton seul
  #
  # Bouton nu, sans classe supplémentaire : sa largeur s’ajuste au libellé. Le retour de copie passe
  # par le contrôleur Stimulus `clipboard`, avec une zone de statut invisible à l’écran annoncée aux
  # lectrices et lecteurs d’écran.
  #
  # **Où** : espace instruction, en-tête de `instruction/forms/show` et de
  # `instruction/authorization_definitions/show`, à droite du titre.
  def default
    render Atoms::CopyButtonComponent.new(
      text_to_copy: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      label: 'Copier le lien de demande'
    )
  end

  # @label 2. Bouton tel qu’il apparaît dans le produit (largeur alignée)
  #
  # Rendu réel : la classe `authorization-definition-action-btn` aligne la largeur du bouton sur
  # celle de « Initier une demande pour autrui », affiché juste au-dessus quand un chemin
  # d’initiation est fourni.
  #
  # **Où** : espace instruction, en-tête de `instruction/forms/show` et de
  # `instruction/authorization_definitions/show`, à droite du titre, rendu par
  # `Atoms::FormButtonsComponent`.
  def with_extra_classes
    render Atoms::CopyButtonComponent.new(
      text_to_copy: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      label: 'Copier le lien de demande',
      extra_classes: 'authorization-definition-action-btn'
    )
  end
end
