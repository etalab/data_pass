# language: fr

Fonctionnalité: Création inline d'un fournisseur de données depuis le formulaire de type

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  @javascript
  Scénario: Créer un nouveau fournisseur de données depuis le formulaire de type
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Alors la page contient "Fournisseur"
    Quand je clique sur "Ajouter un fournisseur de données"
    Alors le formulaire de création est visible
    Quand je remplis le champ fournisseur "Nom" avec "Mon API"
    Et que je remplis le champ fournisseur "Lien" avec "https://mon-api.fr"
    Et que je clique sur "Créer le fournisseur"
    Alors le formulaire de création est masqué
    Et la liste déroulante contient "Mon API"
    Et "Mon API" est sélectionné dans la liste déroulante

  @javascript
  Scénario: Un admin supprime un fournisseur de données sans types liés
    Et qu'un fournisseur de données "Mon Fournisseur" existe
    Quand je me rends sur le chemin "/admin/fournisseurs-donnees"
    Et que je clique sur "Supprimer" et confirme dans la modale
    Alors il y a un message de succès contenant "Mon Fournisseur"
    Et la page contient "Aucun fournisseur de données"

  Scénario: Le bouton supprimer n'est pas affiché pour un fournisseur avec des types liés
    Et qu'un fournisseur de données "Mon Fournisseur" avec des types d'habilitation liés existe
    Quand je me rends sur le chemin "/admin/fournisseurs-donnees"
    Alors la page contient "Mon Fournisseur"
    Et la page ne contient pas "Supprimer"

  @javascript
  Scénario: Erreur de validation lors de la création inline
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je clique sur "Ajouter un fournisseur de données"
    Et que je clique sur "Créer le fournisseur"
    Alors le formulaire affiche des erreurs de validation
    Et aucun fournisseur de données n'a été créé
