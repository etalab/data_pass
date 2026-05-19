# language: fr

Fonctionnalité: Admin — Gestion des droits — modifier les droits d’un utilisateur
  En tant qu’administrateur, je peux modifier les droits de n’importe quel
  utilisateur sur n’importe quelle définition, y compris le rôle développeur
  et y compris mes propres droits.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je modifie un rôle existant
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de eva@gouv.fr"
    Alors le select "Rôle" est positionné sur "Observateur"
    Quand je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "eva@gouv.fr" a les rôles "dinum:api_entreprise:instructor"

  Scénario: Je peux modifier un rôle développeur
    Quand il y a l'utilisateur "dev@gouv.fr" avec le rôle "Développeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de dev@gouv.fr"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "dev@gouv.fr" a les rôles "dinum:api_entreprise:instructor"

  Scénario: Je modifie les droits d’un utilisateur sur plusieurs définitions à la fois
    Quand il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de mixte@gouv.fr"
    Et que je sélectionne "Instructeur" pour "Rôle" dans le "Droit 1"
    Et que je sélectionne "Manager" pour "Rôle" dans le "Droit 2"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "mixte@gouv.fr" a les rôles "dinum:api_particulier:manager,dinum:api_entreprise:instructor"

  Scénario: Je peux modifier mes propres droits, mon rôle admin reste affiché en lecture seule
    Quand il y a l'utilisateur "admin@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de admin@gouv.fr"
    Alors la section des droits non modifiables contient le badge "Admin"
    Quand je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "admin@gouv.fr" a les rôles "admin,dinum:api_entreprise:instructor"

  Scénario: Pendant une impersonation, mes actions admin restent attribuées à mon vrai compte
    Quand il y a l'utilisateur "user-x@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "cible@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que j'impersonne l'utilisateur "user-x@gouv.fr"
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient "user-x@gouv.fr"
    Et le tableau des utilisateurs contient "admin@gouv.fr"
    Quand je clique sur "Modifier les droits de cible@gouv.fr"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "cible@gouv.fr" a les rôles "dinum:api_entreprise:instructor"
