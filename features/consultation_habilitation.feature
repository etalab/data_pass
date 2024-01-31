# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation refusée
    Quand je me rends sur une demande d'habilitation "API Entreprise" refusée
    Alors il y a un message d'erreur contenant "a été refusée"

  Scénario: Je consulte une demande d'habilitation simple en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "Portail HubEE - Démarche CertDC" en brouillon
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Alors il y a un bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation simple en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je clique sur "Les demandes ou habilitations de l'organisation"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Alors il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact technique"
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Mes mentions"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il n'y a pas de bouton "Enregistrer"
