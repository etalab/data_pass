# language: fr

Fonctionnalité: Titres de page des formulaires
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents pour les formulaires de demande
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le titre de la page d'introduction d'un nouveau formulaire est correct
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Alors le titre de la page contient "Nouvelle demande API Entreprise - DataPass"

  Scénario: Le titre de la page d'une étape du wizard est correct
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et je me rends sur cette demande d'habilitation
    Alors le titre de la page contient "Informations de base - API Entreprise - Demande libre - DataPass"

  Scénario: Le titre de la page d'un formulaire single-page est correct
    Quand je démarre une nouvelle demande d'habilitation "API CaptchEtat"
    Alors le titre de la page contient "API CaptchEtat - DataPass"