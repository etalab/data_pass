# language: fr

Fonctionnalité: Tableau de bord
  Cette page est la page principale du demandeur, où il peut voir les diverses actions
  qu'il doit effectuer.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois l'ensemble des habilitations quelque soit leur état
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page du tableau de bord
    Et debug
    Alors je vois 4 demandes d'habilitation
