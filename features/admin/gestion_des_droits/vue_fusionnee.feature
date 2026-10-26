# language: fr

Fonctionnalité: Admin — Gestion des droits — vue fusionnée (colonnes et filtres)
  En tant qu’administrateur, je consulte une liste unique des utilisateurs avec
  leurs rôles et leurs droits API, et je peux la filtrer par rôle et par droit.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: La liste expose les colonnes Identité, Organisation, Rôles, Droits et Actions (CA-1)
    Quand il y a l'utilisateur "user@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs a les colonnes "Identité", "Organisation", "Rôles", "Droits" et "Actions"

  Scénario: La liste est paginée à 10 utilisateurs par page (CA-1)
    Quand il y a 11 utilisateurs avec un droit sur "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs ne contient pas "utilisateur-11@gouv.fr"
    Quand je me rends sur le chemin "/admin/gestion-des-droits?page=2"
    Alors le tableau des utilisateurs contient "utilisateur-11@gouv.fr"

  Scénario: Un utilisateur avec un rôle sur tout un FD affiche « Tous les services … » (RG3)
    Quand il y a l'utilisateur "fd@gouv.fr" avec le rôle brut "dinum:*:manager"
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient "Tous les services DINUM"

  Scénario: Un administrateur affiche « Tous les accès » (CA-2)
    Quand il y a l'utilisateur "adminonly@gouv.fr" avec le rôle d'administrateur
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient "Tous les accès"

  Scénario: Le filtre par rôle est littéral, un développeur n’apparaît pas sous « Instructeur » (CA-6)
    Quand il y a l'utilisateur "instructeur@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "developpeur@gouv.fr" avec le rôle "Développeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je sélectionne "Instructeur" dans le filtre "Rôles"
    Et que je clique sur "Rechercher"
    Alors le tableau des utilisateurs contient "instructeur@gouv.fr"
    Et le tableau des utilisateurs ne contient pas "developpeur@gouv.fr"

  Scénario: Le filtre par API ne retient que les droits explicites sur ce formulaire (RG10)
    Quand il y a l'utilisateur "entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "fd@gouv.fr" avec le rôle brut "dinum:*:manager"
    Et que je me rends sur la page de gestion des droits
    Et que je sélectionne "API Entreprise" dans le filtre "Droits"
    Et que je clique sur "Rechercher"
    Alors le tableau des utilisateurs contient "entreprise@gouv.fr"
    Et le tableau des utilisateurs ne contient pas "fd@gouv.fr"

  Scénario: Je réinitialise les filtres pour retrouver toute la liste
    Quand il y a l'utilisateur "instructeur@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je sélectionne "Manager" dans le filtre "Rôles"
    Et que je clique sur "Rechercher"
    Alors la page ne contient pas "instructeur@gouv.fr"
    Quand je clique sur "Réinitialiser"
    Alors le tableau des utilisateurs contient "instructeur@gouv.fr"
