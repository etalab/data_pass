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

  Scénario: Je peux modifier la justification d'un lien vérifié
    Soit l'utilisateur "verified@example.com"
    Et que cet utilisateur appartient à l'organisation "DINUM" avec le SIRET "13002526500013" de manière vérifiée avec la raison "Raison initiale"
    Quand je me rends sur le module "Vérifications organisations" de l'espace administrateur
    Et que je remplis "Email de l’utilisateur" avec "verified@example.com"
    Et que je clique sur "Rechercher"
    Et que je clique sur le premier "Modifier"
    Et que je remplis "Justification" avec "Nouvelle raison"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "justification a été modifiée"
    Et la page contient "Nouvelle raison"

  Scénario: Je peux retirer la vérification d'un lien
    Soit l'utilisateur "verified2@example.com"
    Et que cet utilisateur appartient à l'organisation "DINUM" avec le SIRET "13002526500013" de manière vérifiée avec la raison "Raison test"
    Quand je me rends sur le module "Vérifications organisations" de l'espace administrateur
    Et que je remplis "Email de l’utilisateur" avec "verified2@example.com"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Marquer comme non-vérifié" dans la rangée "13002526500013"
    Alors il y a un message de succès contenant "vérification a été retirée"
