# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation
  Description des différents scénario de consultation en fonction de l'état de l'habilitation,
  du type de formulaire et de la relation entre l'utilisateur courant et l'habilitation
  cible: demandeur, appartenant à l'organisation ou mentionné.

  Seules les habilitations appartenant à l'utilisateur courant possède des actions de modifications.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation refusée m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" refusée
    Alors il y a un message d'erreur contenant "a été refusée"
    Et il n'y a pas de bouton "Sauvegarder"
    Et il n'y a pas de bouton "Soumettre"
    Et il y a un formulaire en mode résumé

  Scénario: Je consulte une demande d'habilitation validée m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Et il n'y a pas de bouton "Sauvegarder"
    Et il n'y a pas de bouton "Soumettre"
    Et il y a un formulaire en mode résumé

  Scénario: Je consulte une demande d'habilitation simple en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "Portail HubEE - Démarche CertDC" en brouillon
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un formulaire en une seule page
    Et il y a un bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en plusieurs étapes
    Et il y a un bouton "Suivant"

  Scénario: Je consulte une demande d'habilitation simple en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je clique sur "Les demandes ou habilitations de l'organisation"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je clique sur "Les demandes ou habilitations de l'organisation"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation simple où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "Portail HubEE - Démarche CertDC" en tant que "Administrateur métier"
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Mes mentions"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Vous avez été référencé comme administrateur métier"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact technique"
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Mes mentions"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Vous avez été référencé comme contact technique"
