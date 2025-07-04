# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API CaptchEtat
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation
    Quand je démarre une nouvelle demande d'habilitation "API CaptchEtat"

    * je renseigne les infos de bases du projet
    * je remplis "Volumétrie approximative" avec "1000 appels par jour"
    * je renseigne les informations du contact technique
    * je clique sur "Enregistrer et continuer"
    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
