# language: fr

Fonctionnalité: Liste des habilitations
  Cette page regroupe l'ensemble des habilitations référencés au sein de DataPass. On peut
  commencer une nouvelle demande d'habilitation depuis cette page.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois l'ensemble des demandes d'habilitations disponibles
    Quand je vais sur la page des demandes
    Alors il y a un titre contenant "Demander une nouvelle habilitation"
    Et la page contient "API Entreprise"
    Et la page contient "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et la page contient "Démarches du bouquet de services (service-public.fr)"
    Et la page contient "API Service National"

  Scénario: Je démarre une nouvelle demande d'habilitation
    Quand je vais sur la page des demandes
    Et que je clique sur "Remplir une demande" pour l'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je clique sur "Débuter"
    Alors il y a un titre contenant "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il y a un bouton "Enregistrer les modifications"

  Scénario: Je démarre une nouvelle demande d'habilitation
    Quand je vais sur la page des demandes
    Et que je clique sur "Remplir une demande" pour l'habilitation "Démarches du bouquet de services (service-public.fr)"
    Et que je clique sur "Débuter"
    Alors il y a un titre contenant "Démarches du bouquet de services (service-public.fr)"
    Et il y a un bouton "Suivant"