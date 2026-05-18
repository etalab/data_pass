# language: fr

Fonctionnalité: Admin — Gestion des droits — lister les utilisateurs avec droits
  En tant qu’administrateur, je peux consulter la liste des utilisateurs qui possèdent
  des droits sur n’importe quelle définition.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je vois les utilisateurs avec des droits sur n’importe quelle définition
    Quand il y a l'utilisateur "user1@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "user2@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page de gestion des droits
    Alors la page contient "user1@gouv.fr"
    Et la page contient "user2@gouv.fr"

  Scénario: Je ne me vois pas dans ma propre liste
    Quand je me rends sur la page de gestion des droits
    Alors la page ne contient pas mon email

  Scénario: Le menu admin contient un lien vers la gestion des droits
    Quand je me rends sur le chemin "/admin"
    Alors la page contient "Gestion des droits"
