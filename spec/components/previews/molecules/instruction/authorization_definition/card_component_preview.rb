# @label Carte d’un formulaire dans la liste
#
# Carte d’une définition d’habilitation — appelée « formulaire » dans l’espace instruction : logo du
# fournisseur de données, nom avec sa mention d’environnement, nom du fournisseur, puis le nombre de
# demandes validées et soumises.
#
# **Où** : espace instruction, page `instruction/authorization_definitions/index`, dans la grille
# filtrée par la barre de recherche.
#
# **Pour qui** : la page est réservée aux personnes ayant le rôle `reporter`
# (`Instruction::AuthorizationDefinitionPolicy#index?`) et ne liste que les formulaires sur lesquels
# elles ont ce droit.
#
# Le logo n’apparaît que si le fournisseur en a un attaché (`provider.logo`) ; sinon le titre occupe
# toute la largeur de la carte.
class Molecules::Instruction::AuthorizationDefinition::CardComponentPreview < ApplicationPreview
  # @label 1. Formulaire avec logo et compteurs
  #
  # Cas complet : le fournisseur a un logo attaché, il occupe la gauche de la carte. Sans logo, le
  # titre prendrait toute la largeur.
  #
  # **Où** : espace instruction, page listant les formulaires
  # (`instruction/authorization_definitions/index`), dans la grille filtrée par la barre de
  # recherche.
  def default
    definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::CardComponent.new(
      authorization_definition: definition,
      validated_count: 1373,
      submitted_count: 6
    )
  end
end
