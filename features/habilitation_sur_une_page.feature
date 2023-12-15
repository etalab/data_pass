# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation simple (sur une seule page)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le formulaire ne possède qu'un bouton de sauvegarde au démarrage
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un bouton "Enregistrer les modifications"
    Et il n'y a pas de bouton "Soumettre la demande d'habilitation"

  Scénario: J'enregistre ma demande d'habilitation
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a un message de succès contenant "sauvegardée avec succès"

