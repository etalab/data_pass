# @label Boutons d’action d’un formulaire
#
# Boutons affichés en haut à droite de l’en-tête d’un formulaire d’habilitation ou d’une définition
# d’habilitation : « Initier une demande pour autrui » et « Copier le lien de demande ».
#
# **Où** : espace instruction, pages `instruction/forms/show` et
# `instruction/authorization_definitions/show`, dans le `with_right_content` du `WideHeader`. **Pour
# qui** : le premier bouton n’apparaît que si `policy([:instruction, definition]).initiate_request?`
# est vrai, c’est-à-dire si les brouillons instructeurs sont activés sur l’API et que la personne
# peut instruire ce type de demande. Sinon, seul le bouton de copie reste — le rendu est alors
# identique à celui de `Atoms::CopyButtonComponent`.
class Atoms::FormButtonsComponentPreview < ApplicationPreview
  # @label 1. Instructeur autorisé à initier une demande
  #
  # Les deux boutons : « Initier une demande pour autrui » au-dessus du bouton de copie du lien.
  #
  # **Où** : en-tête d’un formulaire ou d’une définition d’habilitation, espace instruction, quand
  # `policy([:instruction, definition]).initiate_request?` est vrai.
  def with_initiate_request
    render Atoms::FormButtonsComponent.new(
      copy_request_url: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      initiate_request_path: '/instruction/drafts/api_entreprise/nouveau'
    )
  end

  # @label 2. Sans droit d’initiation (bouton de copie seul)
  #
  # Cas dégradé : sans droit d’initiation, il ne reste que le bouton de copie. Le rendu est alors
  # identique à celui de `Atoms::CopyButtonComponent` — c’est attendu, pas un doublon de preview.
  #
  # **Où** : en-tête d’un formulaire ou d’une définition d’habilitation, espace instruction, pour
  # les API sans brouillons instructeurs ou pour une personne qui n’instruit pas ce type de demande.
  def without_initiate_request
    render Atoms::FormButtonsComponent.new(
      copy_request_url: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau'
    )
  end
end
