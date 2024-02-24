# language: fr

Fonctionnalité: Instruction: historique habilitation
  Une habilitation possède un historique en fonction des actions des demandeurs et instructeurs

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les événements
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a approuvé la demande"
    Et la page contient "a soumis la demande"

