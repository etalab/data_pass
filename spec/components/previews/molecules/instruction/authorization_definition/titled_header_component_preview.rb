# @label En-tête d’une page interne de formulaire
#
# Bandeau bleu réutilisé par les pages internes d’un formulaire : fil d’Ariane, logo du fournisseur,
# titre fourni par la page et nom du formulaire en sous-titre.
#
# **Où** : espace instruction, pages `instruction/authorization_definition_blocks/show` (« Voir les
# étapes du formulaire ») et `instruction/authorization_definition_emails/index` (« Voir les emails
# automatiques »).
#
# **Pour qui** : ces deux pages sont soumises à `Instruction::AuthorizationDefinitionPolicy#show?`.
#
# Seul le titre distingue les deux usages : c’est la page appelante qui le fournit, le composant ne
# le déduit pas.
class Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponentPreview < ApplicationPreview
  # @label 1. Titre « Voir les étapes du formulaire »
  #
  # Le composant tel qu’il apparaît sur la page des étapes : c’est la page appelante qui fournit le
  # titre, le composant ne le déduit pas.
  #
  # **Où** : espace instruction, page « Voir les étapes du formulaire »
  # (`instruction/authorization_definition_blocks/show`), tout en haut.
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponent.new(
      authorization_definition:,
      title: I18n.t('instruction.authorization_definition_blocks.show.title')
    )
  end

  # @label 2. Titre « Voir les emails automatiques »
  #
  # Le second usage du même composant : seul le titre change par rapport au scénario 1, tout le
  # reste du bandeau est identique.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques »
  # (`instruction/authorization_definition_emails/index`), tout en haut.
  def emails
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponent.new(
      authorization_definition:,
      title: I18n.t('instruction.authorization_definition_emails.index.title')
    )
  end
end
