# language: fr

Fonctionnalité: Droits API par fournisseur de données

  Règle: Un administrateur gère les droits

    Contexte:
      Sachant que je suis un administrateur
      Et que je me connecte
      Et que le fournisseur de données de la définition "api_entreprise" s’appelle "Fournisseur Test"
      Et qu’une application OAuth "Application de test" dont le propriétaire est développeur sur "api_entreprise" existe

    Scénario: Un admin accorde un droit de soumission
      Quand je me rends sur le chemin "/admin/acces-api/new"
      Et que je sélectionne "Application de test (dev-test@gouv.fr)" pour "Application"
      Et que je sélectionne "Fournisseur Test" pour "Fournisseur de données"
      Et que je sélectionne "Soumission par API" pour "Droit"
      Et que je remplis "Motif de l’octroi" avec "Parcours qualifié"
      Et que je clique sur "Accorder le droit"
      Alors il y a un message de succès contenant "Le droit API a été accordé"
      Et la page contient "Droits API par fournisseur de données"
      Et la page contient "Application de test"
      Et la page contient "Actif"

    Scénario: Un motif vide est refusé
      Quand je me rends sur le chemin "/admin/acces-api/new"
      Et que je sélectionne "Application de test (dev-test@gouv.fr)" pour "Application"
      Et que je sélectionne "Fournisseur Test" pour "Fournisseur de données"
      Et que je sélectionne "Soumission par API" pour "Droit"
      Et que je clique sur "Accorder le droit"
      Alors la page contient "Motif de l’octroi"
      Et la page ne contient pas "Le droit API a été accordé"

    Scénario: Le même droit ne peut pas être accordé deux fois
      Sachant qu’un droit de soumission est accordé à "Application de test" pour "Fournisseur Test"
      Quand je me rends sur le chemin "/admin/acces-api/new"
      Et que je sélectionne "Application de test (dev-test@gouv.fr)" pour "Application"
      Et que je sélectionne "Fournisseur Test" pour "Fournisseur de données"
      Et que je sélectionne "Soumission par API" pour "Droit"
      Et que je remplis "Motif de l’octroi" avec "Doublon"
      Et que je clique sur "Accorder le droit"
      Alors la page ne contient pas "Le droit API a été accordé"
      Et il y a un message d'erreur contenant "Ce droit est déjà accordé à cette application pour ce fournisseur de données"

    Scénario: Un droit ne peut pas être accordé pour un fournisseur que le propriétaire ne couvre pas
      Sachant qu'un fournisseur de données "Autre fournisseur" existe
      Quand je me rends sur le chemin "/admin/acces-api/new"
      Et que je sélectionne "Application de test (dev-test@gouv.fr)" pour "Application"
      Et que je sélectionne "Autre fournisseur" pour "Fournisseur de données"
      Et que je sélectionne "Soumission par API" pour "Droit"
      Et que je remplis "Motif de l’octroi" avec "Hors périmètre"
      Et que je clique sur "Accorder le droit"
      Alors la page ne contient pas "Le droit API a été accordé"
      Et il y a un message d'erreur contenant "Le fournisseur de données ne correspond à aucun rôle développeur du propriétaire de l’application"

    @javascript
    Scénario: La liste des fournisseurs ne propose que ceux couverts par l’application choisie
      Sachant qu'un fournisseur de données "Autre fournisseur" existe
      Quand je me rends sur le chemin "/admin/acces-api/new"
      Alors la liste "Fournisseur de données" propose "Autre fournisseur"
      Quand je sélectionne "Application de test (dev-test@gouv.fr)" pour "Application"
      Alors la liste "Fournisseur de données" propose "Fournisseur Test"
      Et la liste "Fournisseur de données" ne propose pas "Autre fournisseur"

    Scénario: Un admin retire un droit avec un motif
      Sachant qu’un droit de soumission est accordé à "Application de test" pour "Fournisseur Test"
      Quand je me rends sur le chemin "/admin/acces-api"
      Et que je clique sur "Retirer"
      Et que je remplis "Motif du retrait" avec "Consentement retiré"
      Et que je clique sur "Retirer le droit"
      Alors il y a un message de succès contenant "Le droit API a été retiré"
      Et la page contient "Retiré"
      Et la page contient "Consentement retiré"

    @javascript
    Scénario: Supprimer un fournisseur de données supprime ses droits API
      Sachant qu’un droit de soumission est accordé à "Application de test" pour "Fournisseur Test"
      Et que le fournisseur de données "Fournisseur Test" n’est plus référencé par aucune définition
      Quand je me rends sur le chemin "/admin/fournisseurs-donnees"
      Et que je clique sur "Supprimer" et confirme dans la modale
      Alors il y a un message de succès contenant "Fournisseur Test"
      Quand je me rends sur le chemin "/admin/acces-api"
      Alors la page contient "Aucun droit API n’a été accordé"

    Scénario: Un admin qui impersonne un utilisateur garde l’accès à l’écran
      Étant donné qu'il existe un utilisateur ayant l'email "user@example.com"
      Et que j'impersonne l'utilisateur "user@example.com"
      Quand je me rends sur le chemin "/admin/acces-api"
      Alors la page contient "Droits API par fournisseur de données"

  Règle: Un non-administrateur n’a pas accès

    Scénario: Un demandeur n’accède pas à l’écran
      Sachant que je suis un demandeur
      Et que je me connecte
      Quand je me rends sur le chemin "/admin/acces-api"
      Alors la page ne contient pas "Droits API par fournisseur de données"
