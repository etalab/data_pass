# language: fr

Fonctionnalité: Transfert d'une demande d'habilitation vers une autre organisation
  En tant qu'administrateur
  Je veux pouvoir transférer une demande d'habilitation vers une autre organisation
  Pour corriger des erreurs ou répondre à des demandes de support

  Contexte:
    Étant donné que je suis un administrateur
    Et que je me connecte

  Scénario: Un administrateur peut transférer une demande vers une autre organisation
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" soumise
    Et qu'il existe un utilisateur "nouveau-demandeur@example.com" appartenant à l'organisation "13002526500013"

    Quand je vais sur l'espace administrateur
    Et que je clique sur "Transférer une demande vers une autre organisation"
    Et que je remplis "ID de la demande d'habilitation" avec l'ID de la demande
    Et que je remplis "SIRET de la nouvelle organisation" avec "13002526500013"
    Et que je remplis "Email du nouveau demandeur" avec "nouveau-demandeur@example.com"
    Et que je clique sur "Transférer la demande"

    Alors il y a un message de succès contenant "a été transférée avec succès"
    Et je suis sur la page "Espace administrateur"

  Scénario: Un administrateur ne peut pas transférer si le demandeur n'appartient pas à l'organisation
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" soumise
    Et qu'il existe un utilisateur "utilisateur-cible@example.com" appartenant à l'organisation "13002526500013"
    Et qu'il existe un utilisateur ayant l'email "autre-utilisateur@example.com"

    Quand je vais sur l'espace administrateur
    Et que je clique sur "Transférer une demande vers une autre organisation"
    Et que je remplis "ID de la demande d'habilitation" avec l'ID de la demande
    Et que je remplis "SIRET de la nouvelle organisation" avec "13002526500013"
    Et que je remplis "Email du nouveau demandeur" avec "autre-utilisateur@example.com"
    Et que je clique sur "Transférer la demande"

    Alors il y a un message d'erreur contenant "n'appartient pas à l'organisation"
