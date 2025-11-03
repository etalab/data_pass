# language: fr

Fonctionnalité: Tableau de bord
  Cette page est la page principale de l'utilisateur, où il peut voir les diverses actions
  qu'il doit effectuer.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @demandes @display
  Scénario: Je vois sur l'écran principal l'ensemble de mes demandes d'habilitations et celles de mon organisation vérifiée
  quelque soit leur état
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et j'ai 1 habilitation "API Entreprise" active
    Quand mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 5 demandes d'habilitation

  @demandes @filters @mentions
  Scénario: Je vois les demandes où je suis mentionné
    Quand j'ai 10 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation
    Et la page contient "vous avez été référencé comme contact métier"

  @demandes @filters @status
  Scénario: Je filtre mes demandes par statut
    Quand j'ai 5 demandes d'habilitation "API Entreprise" en brouillon
    Et j'ai 3 demandes d'habilitation "API Entreprise" en attente
    Et j'ai 2 demandes d'habilitation "API Entreprise" refusée
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 10 demandes d'habilitation
    Quand je sélectionne le filtre "Brouillon" pour "Filtrer par statut"
    Et que je clique sur "Rechercher"
    Alors je vois 5 demandes d'habilitation
    Et la page contient "Brouillon"

  @demandes @filters @organization
  Scénario: Je filtre mes demandes par organisation
    Quand j'ai 8 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 3 demandes d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 12 demandes d'habilitation
    Quand je sélectionne le filtre "Toutes les demandes de l'organisation" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Alors je vois 11 demandes d'habilitation

  @demandes @search
  Scénario: Je recherche une demande par texte
    Quand j'ai 1 demande d'habilitation "API Particulier" en brouillon
    Et cette dernière demande d'habilitation s'appelait "Cantine à 1 euro"
    Et j'ai 9 demandes d'habilitation "API Entreprise" en attente
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 10 demandes d'habilitation
    Quand je remplis "Rechercher dans toutes les demandes" avec "Cantine"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demandes d'habilitation
    Et la page contient "Cantine à 1 euro"

  @demandes @affichage_filtres
  Scénario: Le filtre est affiché avec plus de 9 demandes
    Quand j'ai 10 demandes d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Alors la page contient "Rechercher dans toutes les demandes"

  @demandes @organization
  Scénario: Je ne vois pas mes demandes d'une autre organisation
    Sachant que j'ai 3 demandes d'habilitation "API Entreprise" en brouillon
    Et que je suis aussi dans l'organisation "Ville de Lyon"
    Et que je change d'organisation courante pour "Ville de Lyon"
    Et que j'ai 5 demandes d'habilitation "API Entreprise" en attente
    Quand je me rends sur mon tableau de bord demandes
    Alors je vois 5 demandes d'habilitation
    Quand je change d'organisation courante pour mon organisation initiale
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 3 demandes d'habilitation

  @demandes @organization @unverified
  Scénario: Le filtre organisation n'est pas visible pour un utilisateur non vérifié
    Sachant que mon organisation n'est pas vérifiée
    Quand j'ai 10 demandes d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Alors la page contient "Rechercher dans toutes les demandes"
    Et la page ne contient pas "Toutes les demandes de l'organisation"

  @habilitations @display @revoked
  Scénario: Je vois une habilitation révoquée
    Quand j'ai 1 habilitation "API Entreprise" active
    Et que un instructeur a révoqué la demande d'habilitation
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Alors je vois 1 habilitation
    Et la page contient "Révoquée"

  @habilitations @filters @status
  Scénario: Je filtre mes habilitations par statut
    Quand j'ai 6 habilitations "API Entreprise" active
    Et que un instructeur a révoqué la demande d'habilitation
    Et j'ai 5 habilitations "API Particulier" active
    Et que je me rends sur mon tableau de bord habilitations
    Alors je vois 11 habilitation
    Quand je sélectionne le filtre "Révoquée" pour "Filtrer par statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 habilitation
    Et la page contient "Révoquée"

  @habilitations @affichage_filtres
  Scénario: Le filtre est affiché avec plus de 9 habilitations
    Quand j'ai 10 habilitations "API Entreprise" active
    Et que je me rends sur mon tableau de bord habilitations
    Alors la page contient "Rechercher dans toutes les habilitations"

  @transverse @affichage_filtres
  Scénario: Le filtre est spécifique à chaque onglet
    Quand j'ai 10 demandes d'habilitation "API Entreprise"
    Et j'ai 5 habilitations "API Particulier" active
    Et que je me rends sur mon tableau de bord demandes
    Alors la page contient "Rechercher dans toutes les demandes"
    Quand je me rends sur mon tableau de bord habilitations
    Alors la page ne contient pas "Rechercher dans toutes les habilitations"