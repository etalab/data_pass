# @label Liste des emails automatiques
#
# Liste de tous les emails automatiques d’un formulaire, regroupés par événement (soumission,
# validation, demande des modifications, refus, révocation) : un titre et une explication par
# groupe, puis une carte `AutomatedEmailComponent` par email.
#
# **Où** : espace instruction, page `instruction/authorization_definition_emails/index`, sous
# l’en-tête.
#
# **Quand** : les groupes d’événement sans email sont retirés (`event_groups`) et, s’il n’en reste
# aucun, le message « Aucun email automatique n’est envoyé pour ce formulaire. » remplace toute la
# liste.
class Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponentPreview < ApplicationPreview
  # @label 1. Annuaire des Entreprises
  #
  # Le cas de référence : les cinq groupes d’événement sont présents et ne contiennent que les
  # emails standards, au demandeur et à l’instruction, chacun avec sa variante de réouverture.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques »
  # (`instruction/authorization_definition_emails/index`), sous l’en-tête.
  def basic
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('annuaire_des_entreprises')
    )
  end

  # @label 2. API Particulier
  #
  # Seuls « soumission » et « validation » subsistent : les groupes sans email sont retirés, et l’on
  # voit ici ce qu’il advient d’une liste amputée. La validation ajoute le contact RGPD, l’email
  # FranceConnect conditionnel et les emails FranceConnect auto-générés.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques »
  # (`instruction/authorization_definition_emails/index`), sous l’en-tête.
  def with_france_connect_and_embedded_fields
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('api_particulier')
    )
  end

  # @label 3. API FICOBA
  #
  # Le groupe « validation » le plus fourni : au couple standard s’ajoutent deux contacts RGPD
  # (responsable de traitement et délégué à la protection des données) et l’email DGFiP APIM, propre
  # aux formulaires de ce fournisseur.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques »
  # (`instruction/authorization_definition_emails/index`), sous l’en-tête.
  def with_gdpr_and_dgfip
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('api_ficoba')
    )
  end
end
