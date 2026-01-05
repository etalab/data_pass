# language: fr

Fonctionnalité: Espace admin: vérification lien utilisateur / organisation
  En tant qu'administrateur, je peux rechercher un utilisateur par email et vérifier
  les liens entre cet utilisateur et ses organisations.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je peux rechercher un utilisateur par email
    Soit l'utilisateur "test@example.com"
    Et que cet utilisateur appartient à l'organisation "DINUM" avec le SIRET "13002526500013"
    Quand je me rends sur le module "Vérifications organisations" de l'espace administrateur
    Et que je remplis "Email de l’utilisateur" avec "test@example.com"
    Et que je clique sur "Rechercher"
    Alors la page contient "DIRECTION INTERMINISTERIELLE DU NUMERIQUE"
    Et la page contient "13002526500013"

  Scénario: L'utilisateur n'existe pas
    Quand je me rends sur le module "Vérifications organisations" de l'espace administrateur
    Et que je remplis "Email de l’utilisateur" avec "inexistant@example.com"
    Et que je clique sur "Rechercher"
    Alors la page contient "Aucun utilisateur trouvé"

  Scénario: Je peux marquer un lien non vérifié comme vérifié
    Soit l'utilisateur "test@example.com"
    Et que cet utilisateur appartient à l'organisation "DINUM" avec le SIRET "13002526500013" de manière non vérifiée
    Quand je me rends sur le module "Vérifications organisations" de l'espace administrateur
    Et que je remplis "Email de l’utilisateur" avec "test@example.com"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Marquer comme vérifié"
    Et que je remplis "Justification" avec "Vérifié par téléphone"
    Et que je clique sur "Confirmer"
    Alors il y a un message de succès contenant "marqué comme vérifié"
