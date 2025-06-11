# language: fr

Fonctionnalité: Impersonation des utilisateurs
  En tant qu'administrateur
  Je veux pouvoir impersonner un utilisateur
  Pour résoudre des problèmes de support ou déboguer

  Contexte:
    Étant donné que je suis un administrateur
    Et qu'il existe un utilisateur ayant l'email "user@example.com"
    Et que je me connecte

  Scénario: Un administrateur peut impersonner un utilisateur
    Quand je vais sur l'espace administrateur
    Et que je clique sur "Impersonner un utilisateur"
    Et que je remplis "Email de l'utilisateur" avec "user@example.com"
    Et que je remplis "Raison de l'impersonation" avec "Ticket de support #12345"
    Et que je clique sur "Commencer l'impersonation"

    Alors la page contient "Impersonation activée"
    Et il y a un message de succès contenant "Vous êtes maintenant connecté en tant que"
    Et la page contient "Vous (admin@gouv.fr) êtes connecté en tant que user@example.com"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Un administrateur peut arrêter l'impersonation
    Étant donné que j'impersonne l'utilisateur "user@example.com"
    Et que je me rends sur la page d'accueil

    Quand je clique sur "Arrêter l'impersonation"

    Alors la page contient "Impersonation terminée"
    Et la page ne contient pas "Vous êtes maintenant connecté en tant que"

  Scénario: Un administrateur ne peut pas impersonner un utilisateur inexistant
    Quand je me connecte
    Et que je vais sur l'espace administrateur
    Et que je clique sur "Impersonner un utilisateur"

    Quand je remplis "Email de l'utilisateur" avec "inexistant@example.com"
    Et que je remplis "Raison de l'impersonation" avec "Test"
    Et que je clique sur "Commencer l'impersonation"

    Alors je vois "Utilisateur introuvable"
    Et je vois "Aucun utilisateur avec l'email inexistant@example.com"

  Scénario: Un administrateur ne peut pas s'impersonner lui-même
    Quand je me connecte
    Et que je vais sur l'espace administrateur
    Et que je clique sur "Impersonner un utilisateur"

    Quand je remplis "Email de l'utilisateur" avec "admin@gouv.fr"
    Et que je remplis "Raison de l'impersonation" avec "Test"
    Et que je clique sur "Commencer l'impersonation"

    Alors je vois "Erreur"
    Et je vois "Vous ne pouvez pas vous impersonner vous-même"

  Scénario: Les actions effectuées pendant l'impersonation sont enregistrées
    Étant donné qu'il existe une habilitation "api_entreprise" en "bac à sable"
    Et que j'impersonne l'utilisateur "user@example.com"

    Quand je vais sur la page de demandes d'habilitation
    Et que je remplis une demande pour "api_entreprise" en "bac à sable"
    Et que je soumets la demande d'habilitation

    Alors la demande d'habilitation doit être créée au nom de "user@example.com"
    Et une action d'impersonation de type "create" doit être enregistrée pour "AuthorizationRequest"
