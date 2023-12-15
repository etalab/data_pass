# language: fr

Fonctionnalité: Liste des formulaires
  Cette page regroupe l'ensemble des formulaires référencés au sein de DataPass. On peut
  commencer une nouvelle demande d'habilitation depuis cette page.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois l'ensemble des formulaires disponibles
    Quand je vais sur la page des formulaires
    Alors il y a un titre contenant "Demander une nouvelle habilitation"
    Et la page contient "API Entreprise"
    Et la page contient "Portail HubEE - Démarche CertDC"

  Scénario: Je démarre une nouvelle habilitation
    Quand je vais sur la page des formulaires
    Et que je clique sur "Remplir une demande" pour le formulaire "Portail HubEE - Démarche CertDC"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un bouton "Enregistrer les modifications"
