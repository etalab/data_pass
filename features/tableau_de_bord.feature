# language: fr

Fonctionnalité: Tableau de bord
  Cette page est la page principale de l'utilisateur, où il peut voir les diverses actions
  qu'il doit effectuer.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois sur l'écran principal l'ensemble de mes habilitations quelque soit leur état
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je vais sur la page du tableau de bord
    Alors je vois 4 demandes d'habilitation
    Et la page contient "vous êtes le demandeur"

  Scénario: Je vois toutes les habilitations de mon organization
    Quand mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que j'ai 1 demande d'habilitation "API Particulier"
    Et que je vais sur la page du tableau de bord
    Alors je vois 3 demandes d'habilitations

  Scénario: Je vois les habilitations où je suis mentionné
    Quand j'ai 3 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 6 demandes d'habilitation
    Et la page contient "vous avez été référencé comme contact métier"

  Scénario: Je vois une habilitation révoquée
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que un instructeur a révoqué la demande d'habilitation
    Et que je me rends sur mon tableau de bord habilitations
    Alors je vois 1 habilitation
    Et la page contient "Révoquée"

