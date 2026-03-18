# language: fr

Fonctionnalité: Espace admin: types d'habilitation
  En tant qu'administrateur, je peux gérer les types d'habilitation créés via l'interface

  Contexte:
    Sachant que je suis un administrateur

  Scénario: Je vois la liste des types d'habilitation
    Sachant que je me connecte
    Et qu'un type d'habilitation "API Cantine" existe
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Alors la page contient "API Cantine"

  Scénario: La page a le bon titre
    Sachant que je me connecte
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Alors le titre de la page contient "Types d’habilitation"

  Scénario: Je crée un type d'habilitation
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je clique sur "Créer"
    Alors la page contient "API Test"
    Et il y a un message de succès contenant "API Test"

  Scénario: Je crée un type d'habilitation avec un lien CGU
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API CGU Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je remplis "CGU" avec "https://example.com/cgu"
    Et que je clique sur "Créer"
    Alors la page contient "API CGU Test"
    Et il y a un message de succès contenant "créé"

  Scénario: Je crée un type d'habilitation avec un email de support
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Support Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je remplis "Email de support" avec "support@example.com"
    Et que je clique sur "Créer"
    Alors la page contient "API Support Test"
    Et il y a un message de succès contenant "créé"

  Scénario: Un utilisateur non-admin ne peut pas accéder à la liste
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Alors il y a un message d'erreur contenant "n'avez pas le droit"

  Scénario: Je crée un type d'habilitation avec des contacts
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Contacts Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je coche "Contacts"
    Et que je coche "Contact technique"
    Et que je clique sur "Créer"
    Alors la page contient "API Contacts Test"
    Et il y a un message de succès contenant "créé"

  @javascript
  Scénario: Je crée un type d'habilitation avec des scopes
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Scopes Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je coche "Données (scopes)"
    Et que je clique sur "Ajouter un scope"
    Et que je remplis le scope 1 avec nom "Revenu fiscal" valeur "rfr" groupe "Revenus"
    Et que je clique sur "Créer"
    Alors la page contient "API Scopes Test"
    Et il y a un message de succès contenant "créé"

  Scénario: Je ne peux pas créer un type avec le bloc scopes mais sans scope
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Sans Scope"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je coche "Données (scopes)"
    Et que je clique sur "Créer"
    Alors il y a un message d'erreur contenant "erreur"

  Scénario: Je ne peux pas créer un type avec le bloc contacts mais sans type de contact
    Sachant que je me connecte
    Et qu'un fournisseur de données "DINUM" existe
    Quand je me rends sur le chemin "/admin/types-habilitation/new"
    Et que je remplis "Nom du formulaire" avec "API Sans Contact"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je coche "Contacts"
    Et que je clique sur "Créer"
    Alors il y a un message d'erreur contenant "erreur"

  Scénario: Je peux modifier le nom d'un type sans changer son identifiant technique
    Sachant que je me connecte
    Et qu'un type d'habilitation "API Cantine" existe
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Et que je clique sur "Modifier" dans la rangée "API Cantine"
    Et que je remplis "Nom du formulaire" avec "API Cantine V2"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "mis à jour"
    Et la page contient "API Cantine V2"
    Quand je clique sur "Modifier" dans la rangée "API Cantine V2"
    Alors la page contient "api_cantine"

  Scénario: Le bouton supprimer n'est pas affiché pour un type avec des demandes liées
    Sachant que je me connecte
    Et qu'un type d'habilitation "API Protégée" avec des demandes liées existe
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Alors la page contient "API Protégée"
    Et la page contient "Modifier"
    Et la page ne contient pas "Supprimer"

  Scénario: Un admin peut modifier les champs éditoriaux d'un type avec des demandes liées
    Sachant que je me connecte
    Et qu'un type d'habilitation "API Protégée" avec des demandes liées existe
    Quand je me rends sur le chemin "/admin/types-habilitation/api-protegee/edit"
    Et que je remplis "Description" avec "Nouvelle description"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "mis à jour"

  Scénario: Les champs structurels sont désactivés pour un type avec des demandes liées
    Sachant que je me connecte
    Et qu'un type d'habilitation "API Protégée" avec des demandes liées existe
    Quand je me rends sur le chemin "/admin/types-habilitation/api-protegee/edit"
    Alors le champ "Fournisseur" est désactivé
    Et le champ radio "API" est désactivé

