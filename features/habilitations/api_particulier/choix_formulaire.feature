# language: fr

@javascript
Fonctionnalité: Choix du type de formulalire pour API Particulier
  Le choix s'effectue à l'aide d'un arbre de décision en plusieurs étapes, spécifique à API
  Particulier

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je choisis mon équipe de développeurs
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Vos développeurs"
    Alors je vois au moins 1 tuiles
    Et je vois 1 tuile "Demande libre"

  Scénario: Je choisis un éditeur ayant un formulaire
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Votre éditeur"
    Et que je choisis "Aiga"
    Alors je vois 1 tuile
    Et je vois 1 tuile "iNoé"

  Scénario: Je choisis un éditeur inconnu de API Particulier
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Votre éditeur"
    Et que je choisis "Aucun de ces éditeurs"
    Alors la page contient "Vous êtes éligible mais votre éditeur ne semble pas utiliser l'API Particulier"

  Scénario: Je choisis ni équipe technique ni éditeur
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Ni équipe technique, ni éditeur"
    Alors la page contient "Vous êtes éligible mais n'avez pas les prérequis techniques"
