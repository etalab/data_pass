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

  Scénario: Je me vois dans ma propre liste avec mon badge d’admin
    Quand je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient "admin@gouv.fr"
    Et le tableau des utilisateurs contient le badge "Admin"

  Scénario: Je me vois dans ma propre liste avec mes autres rôles
    Quand il y a l'utilisateur "admin@gouv.fr" avec le rôle "Rapporteur" pour "API Entreprise"
    Et que je me rends sur la page de gestion des droits
    Alors le tableau des utilisateurs contient "admin@gouv.fr"
    Et le tableau des utilisateurs contient le badge "Admin"
    Et le tableau des utilisateurs contient le badge "Observateur"

  Scénario: Le menu admin contient un lien vers la gestion des droits
    Quand je me rends sur le chemin "/admin"
    Alors la page contient "Gestion des droits"
