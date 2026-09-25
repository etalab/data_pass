# @label En-tête de la liste des cas d’usage
#
# Bandeau bleu ouvrant la liste des cas d’usage d’un formulaire : fil d’Ariane, logo du fournisseur
# de données, titre « Cas d’usage » et nom du formulaire en sous-titre.
#
# **Où** : espace instruction, page `instruction/forms/index`, tout en haut.
#
# **Pour qui** : la page est soumise à `Instruction::AuthorizationDefinitionPolicy#show?`, donc aux
# personnes ayant un droit de lecture sur ce formulaire.
#
# Le logo n’apparaît que si le fournisseur de données en a un attaché : le bandeau démarre alors
# directement par le titre.
class Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponentPreview < ApplicationPreview
  # @label 1. Cas d’usage d’API Entreprise
  #
  # Unique configuration du composant : titre figé « Cas d’usage » et nom du formulaire en
  # sous-titre. Le logo n’apparaît que parce que le fournisseur en a un attaché ; sans logo, le
  # bandeau démarre directement par le titre.
  #
  # **Où** : espace instruction, liste des cas d’usage d’un formulaire (`instruction/forms/index`),
  # tout en haut de la page.
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponent.new(
      authorization_definition:
    )
  end
end
