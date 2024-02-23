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
    Et la page contient "Vous êtes le demandeur"

  Scénario: Je ne vois pas sur l'écran principal les habilitations de mon organisation
    Quand mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je vais sur la page du tableau de bord
    Alors je vois 0 demande d'habilitation

  Scénario: Je vois toutes les habilitations de mon organization
    Quand mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que j'ai 1 demande d'habilitation "API Particulier"
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Les demandes ou habilitations de l'organisation"
    Alors je vois 3 demandes d'habilitations

  Scénario: Je vois les habilitations où je suis mentionné
    Quand j'ai 3 demandes d'habilitation "API Entreprise"
    Et que mon organisation a 2 demandes d'habilitation "API Entreprise"
    Et que je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact métier"
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Mes mentions"
    Alors je vois 1 demande d'habilitation
    Et la page contient "Vous avez été référencé comme contact métier"

