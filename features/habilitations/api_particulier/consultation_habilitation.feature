# language: fr

Fonctionnalité: Consultation d'une habilitation soumise
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois un lien vers API particulier quand je consulte une habilitation validée
    Quand j'ai déjà une demande d'habilitation "API Particulier" validée avec token
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Particulier"
    Et la page contient un lien vers "particulier.api.gouv.fr"

  Scénario: Je ne vois aucun lien vers API particulier quand je consulte une habilitation non validée
    Quand j'ai déjà une demande d'habilitation "API Particulier" en cours
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Particulier"
    Et la page ne contient aucun lien vers "particulier.api.gouv.fr"
