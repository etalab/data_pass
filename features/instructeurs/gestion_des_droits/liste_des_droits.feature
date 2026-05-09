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
