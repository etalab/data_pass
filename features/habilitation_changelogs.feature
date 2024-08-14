# language: fr

Fonctionnalité: Création de changelog sur les habilitations soumises
  Chaque soumission d'habilitation crée un changelog permettant aux instructeurs de
  comprendre ce qui a été changé ou non.

  Contexte:
    Sachant que je suis un rapporteur "Portail HubEE - Démarche CertDC"
    Et que je me connecte

  @DisableBullet
  Scénario: Je soumets une demande d'habilitation après avoir modifié un champ à la suite d'une demande de modification
    Quand il y a 1 demande d'habilitation "Portail HubEE - Démarche CertDC" en attente de modification
    Et que le demandeur modifie le champ "Nom" avec la valeur "Durand"
    Et que le demandeur soumet la demande
    Et que je me rends sur la dernière demande à instruire
    Et que je clique sur "Historique"
    Alors la page contient "Le champ Nom de famille de l'administrateur système a changé de \"Dupont Administrateur metier\" en \"Durand\""
