# @label Carte d’un email automatique
#
# Carte décrivant un email envoyé automatiquement au cours de la vie d’une demande : statut de la
# demande au moment de l’envoi, condition d’envoi éventuelle, objet, destinataires et corps du
# message.
#
# **Où** : espace instruction, page « Voir les emails automatiques »
# (`instruction/authorization_definition_emails/index`), une carte par email à l’intérieur de chaque
# groupe d’événement de `Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent`.
# **Quand** : l’interrupteur « Afficher l’email de mise à jour » n’apparaît que si un email de
# réouverture existe pour cet événement (`reopening_email`), et le tag de condition seulement si
# l’email dépend d’un état particulier (`condition?`).
#
# La variante « réouverture » est rendue masquée (`fr-hidden`) et ne se révèle qu’au clic sur
# l’interrupteur, via le contrôleur Stimulus `toggle-class` : dans Lookbook, ce second email n’est
# pas visible au chargement.
class Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponentPreview < ApplicationPreview
  # @label 1. Avec interrupteur de réouverture
  #
  # Cas où un email de réouverture existe pour l’événement : l’interrupteur « Afficher l’email de
  # mise à jour » apparaît. Le second email est rendu masqué (`fr-hidden`) et ne se révèle qu’au
  # clic, via le contrôleur Stimulus `toggle-class` — au chargement de la preview, il n’est pas
  # visible.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques », une carte par email à
  # l’intérieur de chaque groupe d’événement.
  def with_reopening_toggle
    definition = AuthorizationDefinition.find('annuaire_des_entreprises')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false }),
      reopening_email: email('AuthorizationRequestMailer', 'reopening_approve', { reopening: true })
    )
  end

  # @label 2. Avec condition d’envoi
  #
  # Email qui ne part que dans un état particulier de la demande : un tag de condition s’ajoute
  # alors en tête de carte, ici « avec FranceConnect ». Sans interrupteur, puisqu’aucun email de
  # réouverture n’est passé.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques », une carte par email à
  # l’intérieur de chaque groupe d’événement.
  def with_condition
    definition = AuthorizationDefinition.find('api_particulier')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('FranceConnectMailer', 'new_scopes', { with_france_connect: true })
    )
  end

  # @label 3. Aperçu impossible (erreur de rendu)
  #
  # Dégradation quand le mailer est introuvable : la carte garde son en-tête et son titre, mais
  # remplace les destinataires et le corps du message par un message d’erreur en rouge, au lieu de
  # faire échouer la page entière.
  #
  # **Où** : espace instruction, page « Voir les emails automatiques », une carte par email à
  # l’intérieur de chaque groupe d’événement.
  def with_error
    definition = AuthorizationDefinition.find('annuaire_des_entreprises')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('UnknownMailer', 'approve', { reopening: false })
    )
  end

  private

  def email(mailer, action, state)
    AuthorizationDefinition::AutomatedEmails::Email.new(mailer:, action:, state:)
  end
end
