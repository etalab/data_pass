# language: fr

Fonctionnalité: Liste des habilitations
  Cette page regroupe l'ensemble des habilitations référencés au sein de DataPass. On peut
  commencer une nouvelle demande d'habilitation depuis cette page.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois l'ensemble des habilitations disponibles
    Quand je vais sur la page des habilitations
    Alors il y a un titre contenant "Demander une nouvelle habilitation"
    Et la page contient "API Entreprise"
    Et la page contient "Portail HubEE - Démarche CertDC"

  Scénario: Je démarre une nouvelle habilitation
    Quand je vais sur la page des habilitations
    Et que je clique sur "Remplir une demande" pour l'habilitation "Portail HubEE - Démarche CertDC"
    Et que je clique sur "Démarrer"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un bouton "Enregistrer les modifications"
