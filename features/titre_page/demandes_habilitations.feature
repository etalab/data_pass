# language: fr

Fonctionnalité: Titres de page des demandes et habilitations
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents pour mes demandes et habilitations
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le titre de la page de récapitulatif d'une demande validée contient le nom de l'API et le nom de la demande
    Quand je me rends sur une demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" validée
    Alors le titre de la page est "Récapitulatif de votre demande - Démarche Certificats de Décès Électroniques Dématérialisés (CertDc) - DataPass"

  Scénario: Le titre de la page d'une habilitation active contient le nom de l'API et le nom de la demande
    Quand j'ai 1 habilitation "API Particulier" active
    Et je visite la page de mon habilitation
    Alors le titre de la page est "Habilitation API Particulier - Demande d'accès à la plateforme fournisseur - DataPass"

