# @label Bloc de configuration d’un formulaire
#
# Encadré « Configuration » récapitulant les réglages d’une définition d’habilitation : type, «
# Démarrable par le demandeur », « Habilitation unique par organisation », fonctionnalités activées
# (messagerie, transfert, demande de modification, initiation par un instructeur), email de support
# et lien d’accès.
#
# **Où** : espace instruction, page `instruction/authorization_definitions/show`, juste sous
# l’en-tête.
#
# **Pour qui** : la page est soumise à `Instruction::AuthorizationDefinitionPolicy#show?`, donc aux
# personnes ayant un droit de lecture sur ce formulaire.
#
# Les lignes « type », « email de support » et « lien d’accès » disparaissent quand la valeur est
# vide : le bloc n’a donc pas le même nombre de lignes d’un formulaire à l’autre.
class Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponentPreview < ApplicationPreview
  # @label 1. API Entreprise
  #
  # Le bloc le plus complet : type « API », les quatre fonctionnalités activées, un email de support
  # et un lien d’accès contenant un gabarit `%{external_provider_id}`, affiché tel quel en `code`.
  #
  # **Où** : espace instruction, fiche d’un formulaire
  # (`instruction/authorization_definitions/show`), juste sous l’en-tête.
  def api_entreprise
    definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end

  # @label 2. API Impôt particulier
  #
  # Variante courte : seule la réouverture est activée et aucun lien d’accès n’est renseigné, donc
  # cette ligne disparaît. À comparer au scénario 1 pour voir que le bloc n’a pas le même nombre de
  # lignes d’un formulaire à l’autre.
  #
  # **Où** : espace instruction, fiche d’un formulaire
  # (`instruction/authorization_definitions/show`), juste sous l’en-tête.
  def api_impot_particulier
    definition = AuthorizationDefinition.find('api_impot_particulier')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end

  # @label 3. HubEE DILA
  #
  # Seul scénario de type « service » plutôt que « API », et seul à porter « Habilitation unique par
  # organisation » à oui : la ligne de type et cette bascule sont ce qui le distingue.
  #
  # **Où** : espace instruction, fiche d’un formulaire
  # (`instruction/authorization_definitions/show`), juste sous l’en-tête.
  def hubee_dila
    definition = AuthorizationDefinition.find('hubee_dila')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end
end
