# language: fr

Fonctionnalité: Instruction: modération
  Un instructeur peut effectuer des actions sur une demande d'habilitation tel que refuser, valider, etc.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que je me rends sur une demande d'habilitation "API Entreprise" à modérer

  Scénario: Je refuse une demande d'habilitation
    Quand je clique sur "Refuser"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 demande d'habilitation "API Entreprise" refusée
    Et il y a un message de succès contenant "a été refusé"
