# language: fr

Fonctionnalité: Instruction: modération
  Un instructeur peut effectuer des actions sur une demande d'habilitation tel que refuser, valider, etc.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il n'y a pas de bouton "Valider"
    Et il n'y a pas de bouton "Refuser"
    Et il n'y a pas de champ éditable

  @AvecCourriels
  Scénario: Je valide une demande d'habilitation
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Entreprise" validée
    Et un email est envoyé contenant "validé"
    Et il y a un message de succès contenant "a été validé"

  @AvecCourriels
  Scénario: Je refuse une demande d'habilitation avec un message valide
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Refuser"
    Et que je remplis "Raison du refus" avec "Vous êtes une entreprise privée"
    Et que je clique sur "Refuser la demande"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Entreprise" refusée
    Et un email est envoyé contenant "Vous êtes une entreprise privée"
    Et il y a un message de succès contenant "a été refusé"

  Scénario: Je refuse une demande d'habilitation avec un message invalide
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Refuser"
    Et que je clique sur "Refuser la demande"
    Alors il y a au moins une erreur sur un champ
