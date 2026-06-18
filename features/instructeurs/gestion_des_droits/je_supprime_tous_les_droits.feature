# language: fr

Fonctionnalité: Instruction — Gestion des droits — supprimer tous les droits d’un utilisateur
  En tant que manager, je peux retirer tous les droits d’un utilisateur dans
  mon périmètre sans altérer ses autres rôles.

  Contexte:
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Et qu'il y a l'utilisateur "datapass@yopmail.com" avec le rôle d'administrateur

  Scénario: Je supprime tous les droits d’un utilisateur depuis la liste
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Supprimer tous les droits de eva@gouv.fr"
    Alors la page contient "Supprimer tous les droits de eva@gouv.fr ?"
    Quand je clique sur "Supprimer tous les droits de l’utilisateur"
    Alors il y a un message de succès contenant "ont été supprimés"
    Et le tableau des utilisateurs ne contient pas "eva@gouv.fr"
    Et le tableau des utilisateurs contient mon email

  Scénario: Les rôles hors de mon périmètre sont préservés lors d’une suppression
    Quand il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "mixte@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Supprimer tous les droits de mixte@gouv.fr"
    Et que je clique sur "Supprimer tous les droits de l’utilisateur"
    Alors il y a un message de succès contenant "ont été supprimés"
    Et l'utilisateur "mixte@gouv.fr" a les rôles "dinum:api_particulier:reporter"

  Scénario: Je peux déclencher la suppression depuis la page d’édition
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur "Modifier les droits de eva@gouv.fr"
    Et que je clique sur "Supprimer tous les droits"
    Alors la page contient "Supprimer tous les droits de eva@gouv.fr ?"
    Quand je clique sur "Supprimer tous les droits de l’utilisateur"
    Alors il y a un message de succès contenant "ont été supprimés"

  Scénario: Je ne peux pas accéder à la confirmation de suppression pour mon propre utilisateur
    Quand je tente d’accéder à la confirmation de suppression de mes propres droits via URL
    Alors il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"
