# language: fr

Fonctionnalité: Instruction — Gestion des droits — portée FD (wildcard)
  En tant que manager de tout un fournisseur de données, je peux accorder
  des droits sur l’ensemble de ses services. Les managers de définition ne
  peuvent pas accorder ces droits élargis.

  Contexte:
    Sachant que je suis un manager de tout "dinum"
    Et que je me connecte
    Et qu'il y a l'utilisateur "datapass@yopmail.com" avec le rôle d'administrateur

  Scénario: J’accorde un rôle sur tous les services d’un FD dont je suis manager
    Quand il y a l'utilisateur "nouveau@gouv.fr" sans rôle
    Et que je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "nouveau@gouv.fr"
    Et que je sélectionne "Tous les services DINUM" pour "Portée des droits"
    Et que je sélectionne "Observateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "nouveau@gouv.fr" a les rôles "dinum:*:reporter"

  Scénario: Un utilisateur avec rôle FD-wildcard apparaît dans la liste
    Quand il y a l'utilisateur "fd@gouv.fr" avec le rôle brut "dinum:*:reporter"
    Et que je me rends sur la page de gestion des droits
    Alors la page contient "fd@gouv.fr"
    Et la page contient "Tous les services DINUM"

  Scénario: Un utilisateur avec à la fois un rôle FD-wildcard et un rôle précis affiche deux lignes
    Quand il y a l'utilisateur "mix@gouv.fr" avec le rôle brut "dinum:*:reporter"
    Et qu'il y a l'utilisateur "mix@gouv.fr" avec le rôle brut "dinum:api_entreprise:instructor"
    Et que je me rends sur la page de gestion des droits
    Alors la page contient "Tous les services DINUM"
    Et la page contient "API Entreprise"

  Scénario: Un manager FD voit bien l’option "Tous les services" pour son FD
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Portée des droits" contient "Tous les services DINUM"
    Et le select "Portée des droits" contient "API Entreprise"
