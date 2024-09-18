# language: fr

@javascript
Fonctionnalité: Choix du type de formulalire pour API Entreprise
  Le choix s'effectue à l'aide d'un arbre de décision en plusieurs étapes, spécifique à API
  Entreprise

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je choisis mon équipe de développeurs
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Vos développeurs"
    Alors je vois au moins 3 tuiles
    Et je vois 1 tuile "Demande libre"
    Et je vois 1 tuile "Marchés publics"
    Et je vois 1 tuile "Aides publiques"

  Scénario: Je choisis un éditeur ayant un formulaire
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "M"
    Et que je choisis "MGDIS"
    Alors je vois 1 tuile
    Et je vois 1 tuile "Solution Portail des aides"

  Scénario: Je choisis un éditeur inconnu de API Entreprise
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "Aucun de ces éditeurs"
    Alors la page contient "Vous êtes éligible mais votre éditeur ne semble pas utiliser l'API Entreprise"

  Scénario: Je choisis un éditeur qui a déjà intégré API Entreprise sans avoir à demander une habilitation
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "A"
    Et que je choisis "Axyus"
    Alors la page contient "Bonne nouvelle ! Vous êtes éligible et votre éditeur/profil acheteur a déjà intégré l’API Entreprise."

  Scénario: Je choisis ni équipe technique ni éditeur
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et que je choisis "Ni équipe technique, ni éditeur"
    Alors la page contient "Vous êtes éligible mais n'avez pas les prérequis techniques"

  Scénario: Je choisis mon équipe de développeurs avec le paramètre de cas d'usage
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise" avec le paramètre "use_case" égal à "marches_publics"
    Et que je choisis "Vos développeurs"
    Alors je vois 2 tuiles
    Et je vois 1 tuile "Demande libre"
    Et je vois 1 tuile "Marchés publics"

  Scénario: Je choisis un éditeur qui ne correspond pas au paramètre de cas d'usage
  Quand je démarre une nouvelle demande d'habilitation "API Entreprise" avec le paramètre "use_case" égal à "marches_publics"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "M"
    Et que je choisis "MGDIS"
    Alors la page contient "Vous êtes éligible mais votre éditeur ne semble pas utiliser l'API Entreprise"

  Scénario: Je choisis un éditeur qui correspond au paramètre de cas d'usage
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise" avec le paramètre "use_case" égal à "marches_publics"
    Et que je choisis "Votre éditeur"
    Et que je clique sur "S"
    Et que je choisis "SETEC"
    Alors je vois 1 tuile
    Et je vois 1 tuile "Dématérialisation des marchés publics"
