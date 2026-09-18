# @label En-tête d’un formulaire
#
# Bandeau bleu en haut de la fiche d’un formulaire : fil d’Ariane, logo du fournisseur, nom du
# formulaire, identifiant technique, compteurs de demandes validées et soumises, et boutons d’action
# à droite.
#
# **Où** : espace instruction, page `instruction/authorization_definitions/show`, tout en haut.
# **Pour qui** : le bouton « Initier une demande pour autrui » n’est rendu que si la vue passe
# `can_initiate_request`, alimenté par `policy([:instruction, definition]).initiate_request?`.
#
# Sans ce droit, la zone de droite ne garde que « Copier le lien de demande » : c’est ce que montre
# le scénario par défaut.
class Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponentPreview < ApplicationPreview
  # @label 1. Sans droit d’initiation
  #
  # Cas courant : `can_initiate_request` n’est pas passé, la zone de droite ne garde donc que «
  # Copier le lien de demande ».
  #
  # **Où** : espace instruction, fiche d’un formulaire
  # (`instruction/authorization_definitions/show`), tout en haut de la page.
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponent.new(
      authorization_definition:,
      validated_count: 1373,
      submitted_count: 6
    )
  end

  # @label 2. Avec le bouton « Initier une demande pour autrui »
  #
  # Même en-tête avec `can_initiate_request` à vrai : un second bouton s’ajoute à droite. En vrai,
  # la vue l’alimente depuis `policy([:instruction, definition]).initiate_request?`.
  #
  # **Où** : espace instruction, fiche d’un formulaire
  # (`instruction/authorization_definitions/show`), tout en haut de la page.
  def with_initiate_request
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponent.new(
      authorization_definition:,
      validated_count: 1373,
      submitted_count: 6,
      can_initiate_request: true
    )
  end
end
