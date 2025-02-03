# language: fr

Fonctionnalité: Espace admin: utilisateurs avec rôles
  En tant qu'administrateur, je peux voir les utilisateurs possédant des rôles. Je peux ajouter et mettre à jours
  des rôles sur les utilisateurs.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je peux consulter la liste des utilisateurs avec des rôles (l'utilisateur courant est inclut car est un administrateur)
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "api-particulier@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et qu'il y a l'utilisateur "datapass@gouv.fr" avec le rôle "Rapporteur" pour "FranceConnect"
    Et qu'il y a l'utilisateur "datapass@gouv.fr" avec le rôle d'administrateur
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Alors la page contient 4 utilisateurs

  Scénario: Je peux chercher un utilisateur ayant un rôle avec son email
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "api-particulier@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je remplis "Rechercher un utilisateur" avec "api-entreprise@gouv.fr"
    Et que je clique sur "Rechercher"
    Alors la page contient 1 utilisateurs
    Et la page contient "api-entreprise@gouv.fr"
    Et la page ne contient pas "api-particulier@gouv.fr"

  Scénario: Je peux chercher un utilisateur avec un rôle
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "api-particulier@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je sélectionne "API Entreprise" pour "API rôle égal à"
    Et que je clique sur "Rechercher"
    Alors la page contient 1 utilisateurs
    Et la page contient "api-entreprise@gouv.fr"

  Scénario: Je ne peux pas chercher un utilisateur sans rôle
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "no-role@gouv.fr" sans rôle
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je remplis "Rechercher un utilisateur" avec "no-role@gouv.fr"
    Et que je clique sur "Rechercher"
    Alors la page ne contient pas "no-role@gouv.fr"

  Scénario: Je peux modifier des rôles sur un utilisateur
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je clique sur "Éditer" pour l'utilisateur "api-entreprise@gouv.fr"
    Et que je remplis "Role" avec "api_entreprise:reporter"
    Et que je clique sur "Mettre à jour"
    Alors il y a un message de succès contenant "mis à jour"
    Et la page contient "api_entreprise:reporter"
    Et la page ne contient pas "api_entreprise:instructor"

  Scénario: Je veux ajouter des rôles à un utilisateur sans rôle
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" sans rôle
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je clique sur "Ajouter des rôles à un utilisateur"
    Et que je remplis "Email" avec "api-entreprise@gouv.fr"
    Et que je remplis "Role" avec "api_entreprise:reporter"
    Et que je clique sur "Mettre à jour"
    Alors il y a un message de succès contenant "mis à jour"
    Et la page contient "api_entreprise:reporter"

  Scénario: Je veux ajouter des rôles à un utilisateur qui n'existe pas
    Quand il y a l'utilisateur "api-entreprise@gouv.fr" sans rôle
    Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
    Et que je clique sur "Ajouter des rôles à un utilisateur"
    Et que je remplis "Email" avec "inconnu@gouv.fr"
    Et que je remplis "Role" avec "api_entreprise:reporter"
    Et que je clique sur "Mettre à jour"
    Alors il y a un message d'erreur contenant "n'existe pas"

