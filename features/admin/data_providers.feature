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
  Scénario: Erreur de validation lors de la création inline
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je clique sur "Ajouter un fournisseur de données"
    Et que je clique sur "Créer le fournisseur"
    Alors le formulaire affiche des erreurs de validation
    Et aucun fournisseur de données n'a été créé
