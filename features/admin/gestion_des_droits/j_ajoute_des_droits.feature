# language: fr

Fonctionnalité: Admin — Gestion des droits — ajouter des droits à un utilisateur
  En tant qu’administrateur, je peux ajouter des droits à un utilisateur sur
  n’importe quelle définition, y compris le rôle développeur.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: J'attribue un rôle développeur à un utilisateur
    Quand il y a l'utilisateur "dev@gouv.fr" sans rôle
    Et que je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "dev@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Développeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "dev@gouv.fr" a les rôles "dinum:api_entreprise:developer"

  Scénario: La liste de portées contient toutes les définitions
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Portée des droits" contient "API Entreprise"
    Et le select "Portée des droits" contient "API Particulier"

  Scénario: La liste des rôles contient développeur mais pas admin
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Rôle" contient "Observateur"
    Et le select "Rôle" contient "Instructeur"
    Et le select "Rôle" contient "Manager"
    Et le select "Rôle" contient "Développeur"
    Et le select "Rôle" ne contient pas "Admin"

  Scénario: Je peux accorder le rôle FD-wildcard sur n’importe quel provider
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Portée des droits" contient "Tous les services DINUM"
