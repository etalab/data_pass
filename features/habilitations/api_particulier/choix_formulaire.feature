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
    Alors je vois au moins 10 tuiles
    Et je vois 1 tuile "Tarification sociale des services municipaux à l’enfance"
    Et je vois 1 tuile "Aides facultatives régionales"
    Et je vois 1 tuile "Aides facultatives départementales"
    Et je vois 1 tuile "Tarification cantine lycées"
    Et je vois 1 tuile "Tarification cantine collèges"
    Et je vois au moins 1 tuile "Aides sociales des CCAS"
    Et je vois 1 tuile "Aides sociales des CCAS dont aides facultatives"
    Et je vois 1 tuile "Tarification des transports"
    Et je vois 1 tuile "Gestion RH du secteur public"
    Et je vois 1 tuile "Demande libre"

  Scénario: Je choisis un éditeur ayant un formulaire
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "E"
    Et que je choisis "Entrouvert"
    Alors je vois 1 tuile
    Et je vois 1 tuile "Publik Famille"

  Scénario: Je choisis un éditeur inconnu de API Particulier
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "Aucun de ces éditeurs"
    Alors la page contient "Vous êtes éligible mais votre éditeur ne semble pas utiliser l'API Particulier"

  Scénario: Je choisis ni équipe technique ni éditeur
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Ni équipe technique, ni éditeur"
    Alors la page contient "Vous êtes éligible mais n'avez pas les prérequis techniques"
