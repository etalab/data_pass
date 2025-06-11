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
    Quand je vais sur l'espace administrateur
    Et que je clique sur "Impersonner un utilisateur"
    Et que je remplis "Email de l'utilisateur" avec "invalid@example.com"
    Et que je remplis "Raison de l'impersonation" avec "Ticket de support #12345"
    Et que je clique sur "Commencer l'impersonation"

    Alors il y a un message d'erreur contenant "Aucun utilisateur trouvé avec cet email"

  Scénario: Un administrateur ne peut pas s'impersonner lui-même
    Quand je vais sur l'espace administrateur
    Et que je clique sur "Impersonner un utilisateur"
    Et que je remplis "Email de l'utilisateur" avec "admin@gouv.fr"
    Et que je remplis "Raison de l'impersonation" avec "Ticket de support #12345"
    Et que je clique sur "Commencer l'impersonation"

    Alors il y a un message d'erreur contenant "Usager ne peut pas être identique à l'administrateur"

  Scénario: Les actions effectuées pendant l'impersonation sont enregistrées
    Quand j'impersonne l'utilisateur "user@example.com"
    Et que je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"

    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    Alors une action d'impersonation de type "create" doit être enregistrée pour "AuthorizationRequest::APIEntreprise"
