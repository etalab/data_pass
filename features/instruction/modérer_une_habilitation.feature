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

  Scénario: Je refuse une demande d'habilitation
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Refuser"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Entreprise" refusée
    Et il y a un message de succès contenant "a été refusé"

  Scénario: Je valide une demande d'habilitation
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Entreprise" validée
    Et il y a un message de succès contenant "a été validé"
