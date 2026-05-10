# language: fr

Fonctionnalité: Instruction — Gestion des droits — modifier les droits d’un utilisateur
  En tant que manager, je peux modifier les droits d’un utilisateur sur les
  définitions que je manage sans altérer ses rôles hors de mon périmètre.

  Contexte:
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Et qu'il y a l'utilisateur "datapass@yopmail.com" avec le rôle d'administrateur

  Scénario: Je modifie un rôle existant
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de eva@gouv.fr"
    Alors le select "Rôle" est positionné sur "Observateur"
    Quand je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "eva@gouv.fr" a les rôles "dinum:api_entreprise:instructor"

  Scénario: Les rôles hors de mon périmètre sont préservés quand je modifie un utilisateur
    Quand il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de mixte@gouv.fr"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors l'utilisateur "mixte@gouv.fr" a les rôles "dinum:api_particulier:reporter,dinum:api_entreprise:instructor"

  Scénario: L’email est affiché en lecture seule dans la section « Informations d’identité »
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de eva@gouv.fr"
    Alors la page ne contient pas le champ "Email de l’utilisateur"
    Et la page contient "Informations d’identité"
    Et la page contient "eva@gouv.fr"

  Scénario: Je ne peux pas modifier mon propre utilisateur via URL forgée
    Quand je tente de modifier mes propres droits via URL
    Alors il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"

  Scénario: Je ne peux pas modifier un utilisateur qui n’a aucun droit sur mon périmètre
    Quand il y a l'utilisateur "externe@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je tente de modifier les droits de "externe@gouv.fr" via URL
    Alors il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"

  Scénario: Un rôle développeur est affiché en lecture seule et préservé lors d’une modification
    Quand il y a l'utilisateur "dev@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "dev@gouv.fr" avec le rôle "Développeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de dev@gouv.fr"
    Alors la page contient "Droits non modifiables depuis cette interface"
    Et la page contient "Développeur"
    Quand je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "dev@gouv.fr" a les rôles "dinum:api_entreprise:developer,dinum:api_entreprise:instructor"
