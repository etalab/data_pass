# language: fr

Fonctionnalité: Instruction — Gestion des droits — ajouter des droits à un utilisateur
  En tant que manager, je peux ajouter des droits à un utilisateur sur les
  définitions que je manage.

  Contexte:
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Et qu'il y a l'utilisateur "datapass@yopmail.com" avec le rôle d'administrateur

  Scénario: J'ajoute un premier rôle à un utilisateur sans droits
    Quand il y a l'utilisateur "nouveau@gouv.fr" sans rôle
    Et que je me rends sur la page de gestion des droits
    Et que je clique sur le premier "Ajouter des droits à un utilisateur sans droits"
    Et que je remplis "Email de l’utilisateur" avec "nouveau@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Observateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et la page contient "nouveau@gouv.fr"
    Et l'utilisateur "nouveau@gouv.fr" a les rôles "dinum:api_entreprise:reporter"

  Scénario: Je ne peux pas ajouter des droits à un utilisateur inexistant
    Quand je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "inconnu@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Observateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors la page contient "ne correspond à aucun utilisateur existant"

  Scénario: La liste de portées ne contient que les définitions que je manage
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Portée des droits" contient "API Entreprise"
    Et le select "Portée des droits" ne contient pas "API Particulier"

  Scénario: Un manager de définition ne peut pas accorder un droit FD-wildcard
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Portée des droits" ne contient pas "Tous les services DINUM"

  Scénario: L’aide sur les droits est disponible via un accordéon
    Quand je me rends sur la page d'ajout de droits
    Alors la page contient l'accordéon "En savoir plus sur les droits" replié par défaut
    Et la page contient "Un service précis"
    Et la page contient "Peut consulter les demandes et habilitations"
    Et la page contient "Peut instruire les demandes"
    Et la page contient "peut attribuer ou retirer des droits"

  Scénario: La liste des rôles ne contient ni admin ni développeur
    Quand je me rends sur la page d'ajout de droits
    Alors le select "Rôle" contient "Observateur"
    Et le select "Rôle" contient "Instructeur"
    Et le select "Rôle" contient "Manager"
    Et le select "Rôle" ne contient pas "Développeur"
    Et le select "Rôle" ne contient pas "Admin"

  Scénario: Je préserve les rôles existants hors de mon périmètre
    Quand il y a l'utilisateur "existant@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "existant@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "existant@gouv.fr" a les rôles "dinum:api_particulier:reporter,dinum:api_entreprise:instructor"
