# language: fr

Fonctionnalité: Supprimer une habilitation
  Un demandeur peut supprimer une de ses habilitations en brouillon

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le bouton "Supprimer" est présent sur une habilitation m'appartenant en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il y a un bouton "Supprimer"

  Scénario: Le bouton "Supprimer" n'est pas présent sur une habilitation m'appartenant validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Alors il n'y a pas de bouton "Supprimer"

  Scénario: Le bouton "Supprimer" n'est pas présent sur une habilitation de mon organisation en brouillon
    Quand mon organisation a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que je clique sur "Toutes celles de l'organisation"
    Et que je clique sur "Consulter"
    Alors il n'y a pas de bouton "Supprimer"

  Scénario: J'supprime une de mes habilitations en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Et que je clique sur "Supprimer"
    Et que je clique sur "Supprimer la demande"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message de succès contenant "a été supprimée"
    Et Un webhook avec l'évènement "archive" est envoyé

