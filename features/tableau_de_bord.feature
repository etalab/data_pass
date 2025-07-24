# language: fr

Fonctionnalité: Tableau de bord
  Cette page est la page principale de l'utilisateur, où il peut voir les diverses actions
  qu'il doit effectuer.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois sur l'écran principal l'ensemble de mes demandes d'habilitations quelque soit leur état
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et j'ai 1 habilitation "API Entreprise" active
    Quand mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 3 demandes d'habilitation

  Scénario: Je vois les demandes où je suis mentionné
    Quand j'ai 3 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation
    Et la page contient "vous avez été référencé comme contact métier"

  Scénario: Je vois une habilitation révoquée
    Quand j'ai 1 habilitation "API Entreprise" active
    Et que un instructeur a révoqué la demande d'habilitation
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Alors je vois 1 habilitation
    Et la page contient "Révoquée"

  Scénario: Je filtre mes demandes par statut
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 3 demandes d'habilitation
    Quand je sélectionne le filtre "Brouillon" pour "Filtrer par statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demandes d'habilitation
    Et la page contient "Brouillon"

  Scénario: Je filtre mes demandes par organisation
    Quand j'ai 2 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 2 demandes d'habilitation
    Quand je sélectionne le filtre "Toutes les demandes de l'organisation" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Alors je vois 3 demandes d'habilitation

  Scénario: Je recherche une demande par texte
    Quand j'ai 1 demande d'habilitation "API Particulier" en brouillon
    Et cette dernière demande d'habilitation s'appelait "Cantine à 1 euro"
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 2 demandes d'habilitation
    Quand je remplis "Rechercher dans toutes les demandes" avec "Cantine"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demandes d'habilitation
    Et la page contient "Cantine à 1 euro"

  Scénario: Je filtre mes habilitations par statut
    Quand j'ai 1 habilitation "API Entreprise" active
    Et que un instructeur a révoqué la demande d'habilitation
    Et j'ai 1 habilitation "API Particulier" active
    Et que je me rends sur mon tableau de bord habilitations
    Alors je vois 2 habilitation
    Quand je sélectionne le filtre "Révoquée" pour "Filtrer par statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 habilitation
    Et la page contient "Révoquée"
