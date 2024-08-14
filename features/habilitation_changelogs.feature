# language: fr

Fonctionnalité: Création de changelog sur les habilitations soumises
  Chaque soumission d'habilitation crée un changelog permettant aux instructeurs de
  comprendre ce qui a été changé ou non.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @DisableBullet
  Scénario: Je soumets une demande d'habilitation après avoir modifié un champ à la suite d'une demande de modification
    Quand je me rends sur une demande d'habilitation "Portail HubEE - Démarche CertDC" à modifier
    Et que je clique sur "Modifier"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    |
      | Durand |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Soumettre"
    Et que je suis un rapporteur "Portail HubEE - Démarche CertDC"
    Et que je me rends sur la dernière demande à instruire
    Et que je clique sur "Historique"
    Alors la page contient "Le champ Nom de famille de l'administrateur système a changé de \"Dupont Administrateur metier\" en \"Durand\""
