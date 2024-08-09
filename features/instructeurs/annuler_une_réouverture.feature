# language: fr

Fonctionnalité: Instruction: annuler une réouverture
  Un instructeur peut annuler une réouverture d'un usager en précisant une raison

  Contexte:
    Sachant que je suis un instructeur "API Particulier"
    Et que je me connecte

  Scénario: Je peux annuler une réouverture sur une habilitation réouverte
    Quand je me rends sur une demande d'habilitation "API Particulier" réouverte
    Alors il y a un bouton "Annuler la demande de réouverture"

  Scénario: Je ne peux pas annuler une réouverture sur une habilitation qui n'a jamais été réouverte
    Quand je me rends sur une demande d'habilitation "API Particulier" à modérer
    Alors il n'y a pas de bouton "Annuler la demande de réouverture"

  Scénario: J'annule une réouverture d'habilitation avec un message valide
    Quand je me rends sur une demande d'habilitation "API Particulier" réouverte
    Et que je clique sur "Annuler la demande de réouverture"
    Et que je remplis "Raison de l'annulation de la réouverture" avec "L'usager s'est trompé de bouton"
    Et que je clique sur "Annuler la réouverture de cette demande"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Particulier" validée

  Scénario: J'annule une réouverture d'habilitation avec un message invalide
    Quand je me rends sur une demande d'habilitation "API Particulier" réouverte
    Et que je clique sur "Annuler la demande de réouverture"
    Et que je clique sur "Annuler la réouverture de cette demande"
    Alors il y a au moins une erreur sur un champ

