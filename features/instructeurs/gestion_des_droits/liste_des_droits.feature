# language: fr

Fonctionnalité: Instruction — Gestion des droits — lister les utilisateurs avec droits
  En tant que manager, je peux consulter la liste des utilisateurs qui possèdent
  des droits sur les définitions que je manage.

  Contexte:
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les utilisateurs avec des droits sur les définitions que je manage
    Quand il y a l'utilisateur "user1@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "user2@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Alors la page contient "user1@gouv.fr"
    Et la page ne contient pas "user2@gouv.fr"

  Scénario: Lorsque personne d’autre n’a de droits, je ne vois que ma propre ligne
    Quand je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient mon email
    Et la page contient "Ajouter des droits"

  Scénario: L’écran d’instruction s’appelle « Gestion des rôles »
    Quand je me rends sur la page de gestion des droits
    Alors la page contient "Gestion des rôles"
    Et la page contient "Les personnes qui ont un rôle sur vos services"
    Et la page ne contient pas "Utilisateurs et rôles"

  Scénario: Je me vois dans ma propre liste, sans bouton d’édition
    Quand je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient mon email
    Et ma ligne n’affiche aucun bouton de modification ni de suppression
    Et ma ligne indique que seul un autre manager ou un administrateur peut modifier mes droits

  Scénario: Un droit sur tous les services du fournisseur n’est modifiable que par son manager
    Quand il y a l'utilisateur "fd@gouv.fr" avec le rôle brut "dinum:*:reporter"
    Et que je me rends sur la page de gestion des droits
    Alors la ligne de "fd@gouv.fr" n’affiche pas de bouton de modification
    Et la ligne de "fd@gouv.fr" indique que ses droits relèvent d’un manager du fournisseur

  Scénario: Le champ de recherche est auto-soumis sans prendre le focus de lui-même
    Quand je me rends sur la page de gestion des droits
    Alors le champ de recherche est auto-soumis sans prendre le focus

  @javascript
  Scénario: La recherche garde le focus quand la liste se met à jour
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je tape "alice" dans le champ de recherche
    Alors le tableau des utilisateurs ne contient plus mon email
    Et le champ de recherche a toujours le focus

  Scénario: Un reporter n'a pas accès à la gestion des droits
    Étant donné que je suis un rapporteur "API Entreprise"
    Quand je me rends sur le chemin "/instruction/utilisateurs-et-roles"
    Alors la page ne contient pas "Gestion des rôles"

  Scénario: Je peux filtrer la liste avec une recherche
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "bob@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je remplis "Rechercher un utilisateur" avec "alice"
    Et que je clique sur "Rechercher"
    Alors la page contient "alice@gouv.fr"
    Et la page ne contient pas "bob@gouv.fr"
    Et la zone de statut de recherche annonce "1 utilisateur"

  Scénario: Empty state lorsque la recherche ne renvoie aucun résultat
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je remplis "Rechercher un utilisateur" avec "introuvable"
    Et que je clique sur "Rechercher"
    Alors la page contient "Aucun utilisateur ne correspond à votre recherche"
    Et la zone de statut de recherche annonce "Aucun utilisateur ne correspond à votre recherche"
    Et la page ne contient pas "alice@gouv.fr"

  Scénario: Une recherche vide affiche la liste scopée complète
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "zoe@gouv.fr" avec le rôle "Instructeur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Et que je remplis "Rechercher un utilisateur" avec ""
    Et que je clique sur "Rechercher"
    Alors la page contient "alice@gouv.fr"
    Et la page ne contient pas "zoe@gouv.fr"
    Et la page ne contient pas "Aucun utilisateur ne correspond à votre recherche"
