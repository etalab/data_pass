# language: fr

Fonctionnalité: Titres de page des demandes et habilitations
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents pour mes demandes et habilitations
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le titre de la page de récapitulatif d'une demande validée est Récapitulatif de votre demande API Entreprise
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Alors le titre de la page contient "Récapitulatif de votre demande API Entreprise - Demande d'accès à la plateforme fournisseur - DataPass"

  Scénario: Le titre de la page d'une habilitation active est Habilitation API Entreprise
    Quand j'ai 1 habilitation "API Entreprise" active
    Et je visite la page de mon habilitation
    Alors le titre de la page contient "Habilitation API Entreprise - Demande d'accès à la plateforme fournisseur - DataPass"

