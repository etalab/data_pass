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

  Scénario: Empty state lorsque personne n'a de droits
    Quand je me rends sur la page de gestion des droits
    Alors la page contient "Aucun utilisateur ne possède de droits pour l’instant"
    Et la page contient "Ajouter des droits à un utilisateur sans droits"

  Scénario: Je ne me vois pas dans ma propre liste
    Quand je me rends sur la page de gestion des droits
    Alors la page ne contient pas mon email

  Scénario: Un reporter n'a pas accès à la gestion des droits
    Étant donné que je suis un rapporteur "API Entreprise"
    Quand je me rends sur le chemin "/instruction/gestion-des-droits"
    Alors la page ne contient pas "Gestion des droits"

  Scénario: Je peux filtrer la liste avec une recherche
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "bob@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je remplis "Rechercher un utilisateur" avec "alice"
    Et que je clique sur "Rechercher"
    Alors la page contient "alice@gouv.fr"
    Et la page ne contient pas "bob@gouv.fr"

  Scénario: Empty state lorsque la recherche ne renvoie aucun résultat
    Quand il y a l'utilisateur "alice@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Et que je remplis "Rechercher un utilisateur" avec "introuvable"
    Et que je clique sur "Rechercher"
    Alors la page contient "Aucun utilisateur ne correspond à votre recherche"
    Et la page ne contient pas "alice@gouv.fr"
