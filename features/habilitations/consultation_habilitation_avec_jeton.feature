# language: fr

Fonctionnalité: Consultation d'une habilitation validée avec jeton d'accès référencé
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois un lien vers API particulier quand je consulte une habilitation validée
    Quand j'ai 1 demande d'habilitation "API Particulier" validée
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Particulier"
    Et la page contient un lien vers "particulier.api.gouv.fr"

  Scénario: Je ne vois aucun lien vers API particulier quand je consulte une habilitation non validée
    Quand j'ai 1 demande d'habilitation "API Particulier"
    Et que je me rends sur mon tableau de bord demandes
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Particulier"
    Et la page ne contient aucun lien vers "particulier.api.gouv.fr"
