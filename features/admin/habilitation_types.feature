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
    Et que je remplis "Nom" avec "API Test"
    Et que je sélectionne "DINUM" pour "Fournisseur"
    Et que je choisis le type "API"
    Et que je clique sur "Créer"
    Alors la page contient "API Test"
    Et il y a un message de succès contenant "créé"

  Scénario: Un utilisateur non-admin ne peut pas accéder à la liste
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/admin/types-habilitation"
    Alors il y a un message d'erreur contenant "n'avez pas le droit"
