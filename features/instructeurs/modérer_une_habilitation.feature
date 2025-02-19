# language: fr

Fonctionnalité: Instruction: modération
  Un instructeur peut effectuer des actions sur une demande d'habilitation tel que refuser, valider, etc.

  Contexte:
    Sachant que je suis un instructeur "API scolarité de l'élève"
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation en brouillon
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" en brouillon
    Alors il n'y a pas de bouton "Valider"
    Et il n'y a pas de bouton "Refuser"
    Et il n'y a pas de champ éditable

  @AvecCourriels
  Scénario: Je valide une demande d'habilitation
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API scolarité de l'élève" validée
    Et un email est envoyé contenant "validé"
    Et un email est envoyé contenant "vous a désigné(e) comme Délégué à la protection des données"
    Et il y a un message de succès contenant "a été validé"

  @FlushJobQueue
  Scénario: Je valide une demande d'habilitation qui déclenche un webhook
    Sachant que je suis un instructeur "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors un webhook avec l'évènement "approve" est envoyé

  @AvecCourriels
  Scénario: Je refuse une demande d'habilitation avec un message valide
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" à modérer
    Et je clique sur "Refuser"
    Et que je remplis "Raison du refus" avec "Vous êtes une entreprise privée"
    Et que je clique sur "Refuser la demande d'habilitation"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API scolarité de l'élève" refusée
    Et un email est envoyé contenant "Vous êtes une entreprise privée"
    Et il y a un message de succès contenant "a été refusé"

  @FlushJobQueue
  Scénario: Je refuse une demande d'habilitation qui déclenche un webhook
    Sachant que je suis un instructeur "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Refuser"
    Et que je remplis "Raison du refus" avec "Vous êtes une entreprise privée"
    Et que je clique sur "Refuser la demande d'habilitation"
    Alors un webhook avec l'évènement "refuse" est envoyé

  Scénario: Je refuse une demande d'habilitation avec un message invalide
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" à modérer
    Et je clique sur "Refuser"
    Et que je clique sur "Refuser la demande"
    Alors il y a au moins une erreur sur un champ

  @AvecCourriels
  Scénario: Je demande des modifications sur une demande d'habilitation avec un message valide
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" à modérer
    Et je clique sur "Demander des modifications"
    Et que je remplis "Raison de la demande de modification" avec "Précisez votre cas d'usage"
    Et que je clique sur "Envoyer la demande de modification"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API scolarité de l'élève" en attente de modification
    Et un email est envoyé contenant "Précisez votre cas d'usage"
    Et il y a un message de succès contenant "demande de modifications"

  @FlushJobQueue
  Scénario: Je demande des modifications sur une demande d'habilitation qui déclenche un webhook
    Sachant que je suis un instructeur "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Demander des modifications"
    Et que je remplis "Raison de la demande de modification" avec "Précisez votre cas d'usage"
    Et que je clique sur "Envoyer la demande de modification"
    Alors un webhook avec l'évènement "request_changes" est envoyé

  Scénario: Je demande des modifications sur une demande d'habilitation avec un message invalide
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" à modérer
    Et je clique sur "Demander des modifications"
    Et que je clique sur "Envoyer la demande de modification"
    Alors il y a au moins une erreur sur un champ

  Scénario: Je supprime une demande d'habilitation
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" en brouillon
    Et je clique sur "Supprimer"
    Et je clique sur "Supprimer la demande"
    Alors je suis sur la page "Liste des demandes en cours"
    Et il y a un message de succès contenant "a été supprimée"

  @FlushJobQueue
  Scénario: Je supprime une demande d'habilitation qui déclenche un webhook
    Sachant que je suis un instructeur "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Et je clique sur "Supprimer"
    Et je clique sur "Supprimer la demande"
    Alors un webhook avec l'évènement "archive" est envoyé
